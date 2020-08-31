/************************************************************
 * Code formatted by SoftTree SQL Assistant © v4.6.12
 * Time: 12/24/2012 12:10:27 PM
 ************************************************************/

IF OBJECT_ID(N'FNAAvg', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAAvg]
GO 

CREATE FUNCTION [dbo].[FNAAvg]
(
	@arg1  FLOAT,
	@arg2  FLOAT
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @x AS FLOAT
	
	SET @x = CASE WHEN @arg1 IS NULL THEN @arg2 WHEN @arg2 IS NULL THEN @arg1 ELSE (@arg1 + @arg2) / 2 END
	
	RETURN @x
END	