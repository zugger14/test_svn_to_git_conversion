/****** Object:  UserDefinedFunction [dbo].[FNARStaticCurve]    Script Date: 09/15/2011 11:41:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARStaticCurve]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARStaticCurve]
GO

/****** Object:  UserDefinedFunction [dbo].[FNARStaticCurve]    Script Date: 09/15/2011 11:41:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNARStaticCurve](
		@maturity_date DATETIME,
		@as_of_date DATETIME,
		@granularity INT,
		@curve_source_value_id INT,
		@hr INT, 
		@mins INT,
		@is_dst INT
	)
RETURNS FLOAT AS  
BEGIN 
	DECLARE @value FLOAT

	SELECT @as_of_date = MAX(as_of_date) 
		FROM source_price_curve 
	WHERE 
		source_curve_def_id = @curve_source_value_id
		--AND as_of_date <= @as_of_date

	DECLARE @settlement_curve_id		INT
	DECLARE @settlement_maturity_date	DATETIME
	DECLARE @pnl_as_of_date				DATETIME
	DECLARE @settlement_granularity		INT 
	DECLARE @min_d						VARCHAR(2)
	DECLARE	@as_of_date_eom				DATETIME
	
	DECLARE @maturity_date_980 DATETIME, @maturity_date_981 DATETIME,
	@maturity_date_993 DATETIME, @maturity_date_var DATETIME
	
	DECLARE @maturity AS VARCHAR(30)
	DECLARE @qtr_min AS VARCHAR(2);	

	SELECT @granularity = granularity FROM source_price_curve_def spcd WHERE source_curve_def_id = @curve_source_value_id
	
	IF @granularity IN (987,989,981,993,994,995)
		SET @as_of_date = @maturity_date
		
	--RETURN @granularity
	IF(@granularity NOT IN(987,989,994,995))
	BEGIN		
		IF @hr IS NULL
			SET @hr = 0

		IF @mins IS NULL
			SET @mins = 0
			
		SELECT @maturity_date_var = CASE WHEN spcd.Granularity IN (980) THEN CONVERT(VARCHAR(8),@maturity_date,120) + '01'
		WHEN spcd.Granularity IN (993) THEN CAST(YEAR(@maturity_date) AS VARCHAR) + '-01-01' ELSE @maturity_date END
		FROM source_price_curve_def spcd where spcd.source_curve_def_id = @curve_source_value_id

		SET @is_dst=ISNULL(@is_dst,0) 	

		SET @min_d = '00'
	
		IF @hr > 0
			SET @hr = @hr - 1

		--RETURN(@granularity)
		SET @as_of_date_eom = CASE WHEN @granularity = 980 THEN DATEADD(m,1,CAST(CONVERT(VARCHAR(7),@as_of_date,120)+'-01' AS DATETIME))-1 
		WHEN @granularity = 993 THEN CAST(YEAR(@as_of_date) AS VARCHAR) + '-' +'12-31' END
			
		IF ((@granularity IN(980) AND ((MONTH(@maturity_date) = MONTH(@as_of_date) AND @as_of_date>=@as_of_date_eom AND @maturity_date<=@as_of_date) OR (MONTH(@maturity_date) <> MONTH(@as_of_date) AND @maturity_date<=@as_of_date)))
		OR((@granularity IN(993) AND ((YEAR(@maturity_date) = YEAR(@as_of_date) AND @as_of_date>=@as_of_date_eom AND @maturity_date<=@as_of_date) OR (YEAR(@maturity_date) <> YEAR(@as_of_date) AND @maturity_date<=@as_of_date))))
		OR(@granularity IN(981,982,987,994,995) AND  @maturity_date<=@as_of_date))
		BEGIN
			SELECT @settlement_curve_id = ISNULL(spcd_s.source_curve_def_id, spcd.source_curve_def_id), 
				@settlement_maturity_date = CASE WHEN (hg.hol_date IS NULL AND 
				ISNULL(spcd_s.Granularity, spcd.Granularity) IN(981,982,987,994,995)) THEN @maturity_date ELSE hg.hol_date END, 
				@pnl_as_of_date = CASE WHEN (hg.hol_date IS NULL AND 
				ISNULL(spcd_s.Granularity, spcd.Granularity) IN(981,982,987,994,995)) THEN @maturity_date ELSE hg.exp_date END, 
				@settlement_granularity = spcd.Granularity	 
			FROM 
			source_price_curve_def spcd LEFT JOIN
			source_price_curve_def spcd_s ON spcd_s.source_curve_def_id  = spcd.SETtlement_curve_id LEFT  JOIN
			holiday_group hg ON hg.hol_group_value_id = ISNULL(spcd_s.exp_calENDar_id, spcd.exp_calENDar_id)
			WHERE spcd.source_curve_def_id = @curve_source_value_id AND
			(hg.hol_date IS NULL OR
			hg.hol_date = @maturity_date_var)

			SELECT @maturity_date_var = CASE WHEN @settlement_granularity IN (980) THEN CONVERT(VARCHAR(8),@maturity_date,120) + '01'
			WHEN @settlement_granularity IN (993) THEN CAST(YEAR(@maturity_date) AS VARCHAR) + '-01-01' ELSE @maturity_date END
			FROM source_price_curve_def spcd where spcd.source_curve_def_id = @curve_source_value_id

			IF @pnl_as_of_date IS NULL
			BEGIN
				SET @pnl_as_of_date = @maturity_date_var 

				SET @settlement_maturity_date = @pnl_as_of_date
			END
		
			SET @maturity_date = dbo.FNAGetSQLStANDardDate(@settlement_maturity_date) + ' ' + 
			CASE WHEN (@hr < 10) THEN '0' ELSE '' END +
			CAST(@hr AS VARCHAR) + ':' + @min_d + ':00'	
			SELECT @value = spc.curve_value
			FROM 
			source_price_curve spc 
			WHERE 
			spc.source_curve_def_id = @settlement_curve_id AND
			spc.curve_source_value_id = 4500 AND 
			spc.as_of_date = @as_of_date AND
			spc.assessment_curve_type_value_id IN (77,78) AND 
			spc.curve_source_value_id = 4500 AND 
			spc.maturity_date = @maturity_date	AND
			spc.is_dst=@is_dst	
		END
		ELSE
		BEGIN		
			SET @maturity_date = dbo.FNAGetSQLStANDardDate(@maturity_date) + ' ' + 
			CASE WHEN (@hr < 10) THEN '0' ELSE '' END +
			CAST(@hr AS VARCHAR) + ':' + @min_d + ':00'	
													
			SELECT @maturity_date_980 = CONVERT(VARCHAR(8),@maturity_date,120) + '01'
			,@maturity_date_981=@maturity_date
			,@maturity_date_993 =CAST(YEAR(@maturity_date) AS VARCHAR) + '-01-01' 
			,@maturity_date_var =@maturity_date
														
			SELECT @maturity_date_var = CASE  @granularity WHEN 980 THEN @maturity_date_980 WHEN 993 THEN @maturity_date_993 ELSE @maturity_date END										
			SELECT @value = COALESCE(spc.curve_value, spc_p1.curve_value, spc_p2.curve_value, spc_p3.curve_value)
			FROM source_price_curve_def spcd LEFT JOIN 
			source_price_curve_def spcd1 ON spcd1.source_curve_def_id = spcd.proxy_source_curve_def_id LEFT JOIN 
			source_price_curve_def spcd2 ON spcd2.source_curve_def_id = spcd.monthly_index LEFT JOIN 
			source_price_curve_def spcd3 ON spcd3.source_curve_def_id = spcd.proxy_curve_id3 LEFT JOIN 
			source_price_curve spc ON 
			spcd.source_curve_def_id = spc.source_curve_def_id AND
			spc.curve_source_value_id=4500 AND 
			spc.as_of_date = @as_of_date AND
			spc.assessment_curve_type_value_id IN (77,78) AND 
			spc.curve_source_value_id = 4500 AND 
			spc.maturity_date =  @maturity_date_var AND spc.is_dst=@is_dst LEFT JOIN
			source_price_curve spc_p1 ON 
			spcd.proxy_source_curve_def_id = spc_p1.source_curve_def_id AND
			spc_p1.curve_source_value_id=4500 AND 
			spc_p1.as_of_date = @as_of_date AND 
			spc_p1.assessment_curve_type_value_id IN (77,78) AND 
			spc_p1.curve_source_value_id = 4500 AND 
			spc_p1.maturity_date= @maturity_date_var AND spc_p1.is_dst=@is_dst LEFT JOIN		 
			source_price_curve spc_p2 ON 
			spcd.monthly_index = spc_p2.source_curve_def_id AND
			spc_p2.as_of_date = @as_of_date AND 
			spc_p2.curve_source_value_id=4500 AND 
			spc_p2.assessment_curve_type_value_id IN (77,78) AND 
			spc_p2.curve_source_value_id = 4500 AND 
			spc_p2.maturity_date = @maturity_date_var AND spc_p2.is_dst=@is_dst LEFT JOIN				
			source_price_curve spc_p3 ON 
			spcd.proxy_curve_id3 = spc_p3.source_curve_def_id AND
			spc_p3.curve_source_value_id=4500 AND 
			spc_p3.as_of_date = @as_of_date AND 
			spc_p3.assessment_curve_type_value_id IN (77,78) AND 
			spc_p3.curve_source_value_id = 4500 AND 
			spc_p3.maturity_date = @maturity_date_var
			AND spc_p3.is_dst=@is_dst			
			WHERE spcd.source_curve_def_id = @curve_source_value_id 
		END		
	END
	ELSE
	BEGIN		
		IF @granularity IN (987,989)
		BEGIN
			IF @mins = 1 OR @mins=15
				SET @qtr_min = '00';
			ELSE IF @mins = 2 OR @mins=30
				SET @qtr_min = '15';
			ELSE IF @mins = 3 OR @mins=45
				SET @qtr_min = '30';
			ELSE IF @mins = 4 OR @mins=60
				SET @qtr_min = '45';
		END
		ELSE IF @granularity IN(994) -- 10 mins
			SET @qtr_min = RIGHT('00'+CAST(@mins-10 AS VARCHAR),2)	
		ELSE
			SET @qtr_min = RIGHT('00'+CAST(@mins-5 AS VARCHAR),2)		
			
		SET @value = NULL

		IF @hr IS NULL
			RETURN NULL

		SET @hr = @hr - 1
		SET @maturity = dbo.FNAGetSQLStANDardDate(@maturity_date) + ' ' + 
				CASE WHEN (@hr < 10) THEN '0' ELSE '' END +
				CAST(@hr AS VARCHAR) + ':'+@qtr_min+':00'		

		SELECT @value = curve_value
		FROM 
			source_price_curve
		WHERE
			source_curve_def_id = @curve_source_value_id AND
			as_of_date = @maturity_date AND
			assessment_curve_type_value_id = 77 AND --spot daily
			curve_source_value_id = 4500 AND
			dbo.FNAGetSQLStANDardDATETIME(maturity_date) = @maturity
	END
			
	RETURN @value
END
GO

