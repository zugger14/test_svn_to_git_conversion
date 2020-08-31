IF OBJECT_ID(N'FNAMax', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAMax]
 GO 
 
 
CREATE FUNCTION [dbo].[FNAMax]
(
	@arg1  FLOAT,
	@arg2  FLOAT
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @x AS FLOAT
	
	IF @arg1 IS NULL
	    SET @arg1 = 0
	
	IF @arg2 IS NULL
	    SET @arg2 = 0
	
	IF @arg1 > @arg2
	    SET @x = @arg1
	ELSE
	    SET @x = @arg2
	
	RETURN @x
END