IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARAveragePrice]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNARAveragePrice]
GO

CREATE FUNCTION [dbo].[FNARAveragePrice](@maturity_date DATETIME,
										@as_of_date DATETIME,
										@curve_id INT, 
										@block_define_id INT, 
										@aggregation_level INT)
	RETURNS FLOAT AS  
BEGIN 
	
	--DECLARE @maturity_date DATETIME
	--DECLARE @as_of_date DATETIME
	--DECLARE @block_define_id INT
	--DECLARE @curve_id INT
	--DECLARE @aggregation_level INT
		
	DECLARE @avg_price FLOAT
	DECLARE @block_type INT
	DECLARE @baseload_block INT
	DECLARE @curve_granularity INT
	/*
	SET @maturity_date = '2013-7-2'
	SET @as_of_date = '2013-6-28'
	SET @curve_id = 292
	SET @block_define_id = NULL
	SET @aggregation_level = 981
	--*/
	SET @block_type = 12000--dont comment this
	

	SELECT @baseload_block = value_id  FROM static_data_value WHERE [type_id] = 10018 AND code LIKE 'Base Load'
	SELECT @curve_granularity = granularity FROM source_price_curve_def where source_curve_def_id=@curve_id

	IF @block_define_id IS NULL 
	BEGIN 
		SELECT @block_define_id = ISNULL(block_define_id, @baseload_block) 
		FROM source_price_curve_def spcd
		WHERE spcd.source_curve_def_id = @curve_id
	END 
	
	DECLARE @curve_collection TABLE (as_of_date DATETIME, curve_name VARCHAR(300)
									, source_curve_def_id INT, curve_value NUMERIC(30, 18), maturity_date DATETIME)
	DECLARE @baseload_collection TABLE (term_date DATETIME, hr INT, hr_mult INT)

	--collect curve value
	INSERT INTO @curve_collection(as_of_date, curve_name, source_curve_def_id, curve_value, maturity_date)
	SELECT spc.as_of_date
			, spcd.curve_name
			, spcd.source_curve_def_id source_curve_def_id
			, CASE WHEN spc.maturity_date = ISNULL(proxy_curve_data.maturity_date, spc.maturity_date) THEN spc.curve_value ELSE proxy_curve_data.curve_value END curve_value
			, ISNULL(proxy_curve_data.maturity_date, spc.maturity_date)
	FROM source_price_curve spc
	LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = spc.source_curve_def_id
	OUTER APPLY (SELECT CAST(spc_proxy.curve_value AS VARCHAR(1000)) curve_value, maturity_date
					FROM source_price_curve spc_proxy 
					WHERE spc_proxy.source_curve_def_id = spcd.proxy_source_curve_def_id
						AND spc_proxy.as_of_date = @as_of_date
						AND YEAR(spc.maturity_date) = YEAR(@maturity_date)
						AND CASE WHEN @aggregation_level = 980  OR @aggregation_level = 981 THEN MONTH(maturity_date) ELSE 1 END = CASE WHEN @aggregation_level = 980 OR @aggregation_level = 981 THEN MONTH(@maturity_date) ELSE 1 END
						AND CASE WHEN @aggregation_level = 981 THEN DAY(maturity_date) ELSE 1 END = CASE WHEN @aggregation_level = 981 THEN DAY(@maturity_date) ELSE 1 END)  proxy_curve_data
	WHERE 1 = 1
		AND ((spc.as_of_date = @as_of_date AND spcd.Granularity NOT IN(980,993,991,992)) OR (spcd.Granularity IN (980,993,991,992)))
		AND spc.source_curve_def_id = @curve_id 
		AND YEAR(ISNULL(proxy_curve_data.maturity_date, spc.maturity_date)) = YEAR(@maturity_date) 
		AND CASE WHEN @aggregation_level = 980 THEN MONTH(ISNULL(proxy_curve_data.maturity_date, spc.maturity_date)) ELSE 1 END = CASE WHEN @aggregation_level = 980 THEN MONTH(@maturity_date) ELSE 1 END
		AND CASE WHEN @aggregation_level IN(981,982) THEN DAY(ISNULL(proxy_curve_data.maturity_date, spc.maturity_date)) ELSE 1 END = CASE WHEN @aggregation_level  IN(981,982) THEN DAY(@maturity_date) ELSE 1 END
	
	--calulate multiplier based on block type
	INSERT INTO @baseload_collection(term_date, hr, hr_mult)
	SELECT unpvt.term_date
			, CAST(REPLACE(unpvt.[hour], 'hr', '') AS INT) [Hour]
			, unpvt.hr_mult
	FROM (SELECT hb.term_date
				, hb.block_type
				, hb.block_define_id
				, hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10
				, hr11, hr12, hr13, hr14, hr15, hr16, hr17, hr18, hr19, hr20, hr21, hr22, hr23, hr24
			FROM hour_block_term hb
			WHERE block_type = @block_type
				AND block_define_id = @block_define_id
				AND YEAR(term_date) = YEAR(@maturity_date)
				AND ISNULL(dst_group_value_id,102200)=102200 
				AND CASE WHEN @aggregation_level = 980 OR @aggregation_level = 981 THEN MONTH(term_date) ELSE 1 END = CASE WHEN @aggregation_level = 980 OR @aggregation_level = 981 THEN MONTH(@maturity_date) ELSE 1 END
				AND CASE WHEN @aggregation_level = 981 THEN DAY(term_date) ELSE 1 END = CASE WHEN @aggregation_level = 981 THEN DAY(@maturity_date) ELSE 1 END
			) p UNPIVOT (hr_mult FOR [hour] IN (hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10
												, hr11, hr12, hr13, hr14, hr15, hr16, hr17, hr18
												, hr19, hr20, hr21, hr22, hr23, hr24)
			) AS unpvt 
			WHERE 1 = 1 
				AND unpvt.[hr_mult] <> 0

	--calculate curve price according to block type
	IF @curve_granularity IN (982,994,987,989)
	BEGIN
		SELECT @avg_price = AVG(curve_value) 
		FROM @curve_collection cc
		INNER JOIN @baseload_collection bc ON CAST(CONVERT(VARCHAR(10), bc.term_date, 120) + ' ' + CAST((bc.hr - 1) AS VARCHAR) + ':00:00.000' AS DATETIME) = CAST(CONVERT(VARCHAR(10), cc.maturity_date , 120) + ' ' + CAST(datepart(HH,cc.maturity_date) AS VARCHAR) + ':00:00.000' AS DATETIME)
	
	END
	ELSE 
	BEGIN
		SELECT 
			@avg_price = AVG(curve_value)
		FROM @curve_collection cc
	END
	
	--select @avg_price
	RETURN @avg_price
END
GO
