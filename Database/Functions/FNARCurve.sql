IF OBJECT_ID(N'FNARCurve', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNARCurve]
 GO 

--select dbo.FNARCurve('3/1/2004', 4500, '7/1/2004', 1)
--select dbo.FNARCurve('4/1/2004', 4500, '7/1/2004', 1)

CREATE FUNCTION [dbo].[FNARCurve]
(
	@as_of_date             DATETIME,
	@curve_source_value_id  INT,
	@maturity_date          DATETIME,
	@source_curve_def_id    INT,
	@curve_shift_val        FLOAT,
	@curve_shift_per        FLOAT
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @x AS FLOAT
	
	SELECT @curve_shift_val = ISNULL(@curve_shift_val, 0),
	       @curve_shift_per = ISNULL(@curve_shift_per, 1)
	
	
	SELECT @x = (curve_value + @curve_shift_val) * @curve_shift_per
	FROM   source_price_curve
	WHERE  source_curve_def_id = @source_curve_def_id
	       AND as_of_date = @as_of_date
	       AND --		assessment_curve_type_value_id = @assessment_curve_type_value_id and
	           assessment_curve_type_value_id = 77
	       AND --all forward for now
	           curve_source_value_id = @curve_source_value_id
	       AND maturity_date = @maturity_date
	
	RETURN ISNULL(@x, 0)
END



