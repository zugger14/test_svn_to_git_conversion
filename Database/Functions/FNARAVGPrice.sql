IF EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[FNARAVGPrice]') AND [type] IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNARAVGPrice]
GO

CREATE FUNCTION [dbo].[FNARAVGPrice](
	@curve_id INT, 
	@from_month FLOAT,
	@to_month FLOAT,										
	@as_of_date DATETIME
)
RETURNS FLOAT AS  
BEGIN
	DECLARE @avg_price FLOAT,
			@month_from DATETIME,
			@month_to DATETIME
	
	SET @month_from = DATEADD(MONTH, @from_month, CONVERT(VARCHAR(7), @as_of_date, 120) + '-01')
	SET @month_to = DATEADD(MONTH, 1, DATEADD(MONTH, @to_month, CONVERT(VARCHAR(7), @as_of_date, 120) + '-01')) - 1
			
	SELECT @avg_price = AVG(spc.curve_value)
	FROM (
		SELECT spc.source_curve_def_id,
			   MAX(spc.as_of_date) as_of_date,
			   spc.maturity_date 
		FROM source_price_curve spc
		WHERE spc.source_curve_def_id = @curve_id 
			AND spc.maturity_date BETWEEN @month_from AND @month_to 
		GROUP BY spc.maturity_date, spc.source_curve_def_id
	) max_aod
	INNER JOIN source_price_curve spc ON spc.source_curve_def_id = max_aod.source_curve_def_id
		AND spc.as_of_date = max_aod.as_of_date
		AND spc.maturity_date = max_aod.maturity_date
	
	RETURN @avg_price
END
GO