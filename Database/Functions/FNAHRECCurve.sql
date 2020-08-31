/****** Object:  UserDefinedFunction [dbo].[FNAHRECCurve]    Script Date: 07/28/2009 18:08:43 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[FNAHRECCurve]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAHRECCurve]
/****** Object:  UserDefinedFunction [dbo].[FNAHRECCurve]    Script Date: 07/28/2009 18:08:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAHRECCurve] (@he INT
									, @maturity_date DATETIME
									, @curve_source_value_id INT
									, @volume_mult FLOAT
									, @curve_shift_val FLOAT
									, @curve_shift_per FLOAT)
RETURNS FLOAT AS  
BEGIN 
	DECLARE @x AS FLOAT
	DECLARE @maturity VARCHAR(30)

	SELECT @curve_shift_val = ISNULL(@curve_shift_val, 0), @curve_shift_per = ISNULL(@curve_shift_per, 1)

	SET @x = NULL

	IF @he IS NULL
		RETURN NULL

	SET @he = @he - 1
	SET @maturity = dbo.FNAGetSQLStandardDate(@maturity_date) + ' ' + 
			CASE WHEN (@he < 10) THEN '0' ELSE '' END +
			CAST(@he AS VARCHAR) + ':00:00'		

	SELECT @x = (curve_value+ @curve_shift_val) * @curve_shift_per 
	FROM source_price_curve
	WHERE 	source_curve_def_id = @curve_source_value_id AND
		as_of_date = @maturity_date AND
		assessment_curve_type_value_id IN(77,78) AND --spot daily
		curve_source_value_id = 4500 
		AND dbo.FNAGetSQLStandardDateTime(maturity_date) = @maturity
		
	--return isnull(@x, 0)
	RETURN (@x * ISNULL(@volume_mult, 1))
END













