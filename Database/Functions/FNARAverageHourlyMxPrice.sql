/****** Object:  UserDefinedFunction [dbo].[FNARAverageHourlyMxPrice]    Script Date: 06/15/2010 18:30:36 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARAverageHourlyMxPrice]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARAverageHourlyMxPrice]
GO
CREATE FUNCTION [dbo].[FNARAverageHourlyMxPrice](@source_deal_detail_id int,@maturity_date DATETIME,@as_of_date DATETIME,@source_deal_header_id int,@curve_id INT,@block_define_id INT,@process_id varchar(100))
RETURNS float AS  
BEGIN 
-- select dbo.[FNARAverageHourlyMxPrice](NULL,'2012-01-01','2012-01-01',NULL,98,NULL,NULL)
	--DECLARE @source_deal_detail_id int,@maturity_date DATETIME,@as_of_date DATETIME
	DECLARE @contract_id INT
	DECLARE @avg_price float
	DECLARE @block_type INT
	DECLARE @baseload_block INT
--	SET @source_deal_detail_id=919
--	SET @maturity_date='2010-01-01'
--	SET @as_of_date='2010-01-01'
--	SET @curve_id=13
	set @block_type=12000
	
	

		
		
		SELECT @baseload_block = value_id  FROM static_data_value WHERE [type_id] = 10018 AND code LIKE 'Base Load'
		IF @block_define_id IS NULL 
			SELECT  @block_define_id=ISNULL(block_define_id,@baseload_block) 
				FROM source_price_curve_def spcd
				WHERE 
					spcd.source_curve_def_id=@curve_id
	

		;WITH CTE AS (
			SELECT unpvt.term_date,CAST(REPLACE(unpvt.[hour],'hr','') AS INT) [Hour],unpvt.hr_mult FROM 
			(SELECT
					hb.term_date,
					hb.block_type,
					hb.block_define_id,
					hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24
				FROM
					hour_block_term hb
				WHERE block_type=@block_type
					AND block_define_id=@block_define_id
					AND YEAR(term_date) = YEAR(@maturity_date)
					--AND MONTH(term_date) = MONTH(@maturity_date)
			)p
			
				UNPIVOT
				(hr_mult FOR [hour] IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24)
				) AS unpvt 
			WHERE
			unpvt.[hr_mult]<>0
		)


		SELECT @avg_price=
				Max(curve_value)
		FROM
		(		
			SELECT AVG(curve_value) curve_value,[Year],[Month]		
			FROM		
			(		
				SELECT 
					spc.curve_value*ISNULL(hr_mult,0) curve_value,YEAR(maturity_date) [Year],MONTH(maturity_date) [Month]		
				FROM
					source_price_curve spc
					INNER JOIN CTE td on CAST(CONVERT(VARCHAR(10),td.term_date,120)+' '+CAST(td.[Hour]-1 AS VARCHAR)+':00:00.000' AS DATETIME) = spc.maturity_date
					AND spc.source_curve_def_id=@curve_id 
					AND YEAR(maturity_date) = YEAR(@maturity_date)
					--AND MONTH(maturity_date) = MONTH(@maturity_date)
					AND maturity_date<=@as_of_date+' 23:59:59.000'
					
				UNION ALL
				SELECT 
					spc.curve_value curve_value,YEAR(maturity_date) [Year],MONTH(maturity_date) [Month]		
				FROM
					source_price_curve_def spcd
					INNER JOIN source_price_curve_def spcd1 ON spcd1.source_curve_def_id = spcd.proxy_source_curve_def_id
						AND spcd.source_curve_def_id = @curve_id
					INNER JOIN source_price_curve spc ON spc.source_curve_def_id = spcd1.source_curve_def_id
						AND spc.as_of_date  = @as_of_date
						AND YEAR(spc.maturity_date) = YEAR(@maturity_date)
						--AND MONTH(spc.maturity_date) = MONTH(@maturity_date)
						AND spc.maturity_date > @as_of_date+' 23:59:59.000'
						AND day(@as_of_date)<>dbo.FNALastDayInMonth(@as_of_date)
			) a
			GROUP BY [Year],[Month]	
		) b	
		


	RETURN @avg_price
END
