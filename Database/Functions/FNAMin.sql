IF OBJECT_ID(N'FNAMin', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAMin]
GO 
 
CREATE FUNCTION [dbo].[FNAMin]
(
	@arg1  FLOAT,
	@arg2  FLOAT
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @x AS FLOAT
	
	IF @arg1 IS NULL
	   OR @arg2 IS NULL
	    RETURN NULL
	
	IF @arg1 > @arg2
	    SET @x = @arg2
	ELSE
	    SET @x = @arg1
	
	RETURN @x
END






