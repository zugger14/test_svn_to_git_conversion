IF OBJECT_ID(N'FNACurveValue', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNACurveValue]
GO 

--select dbo.FNACurveValue('3/2/2004', 99, 14)

CREATE FUNCTION [dbo].[FNACurveValue]
(
	@as_of_date                      DATETIME,
	@maturity_date                   DATETIME,
	@assessment_curve_type_value_id  INT,
	@curve_source_value_id           INT,
	@source_curve_def_id             INT
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @x AS FLOAT
	SET @x = NULL
	
	SELECT @x = curve_value
	FROM   source_price_curve
	WHERE  source_curve_def_id = @source_curve_def_id
	       AND as_of_date = @as_of_date
	       AND assessment_curve_type_value_id = @assessment_curve_type_value_id
	       AND curve_source_value_id = @curve_source_value_id
	       AND maturity_date = @maturity_date
	
	RETURN @x
END