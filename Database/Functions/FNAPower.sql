IF OBJECT_ID(N'FNAPower', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNAPower]
GO
 
CREATE FUNCTION [dbo].[FNAPower]
(
	@arg1  FLOAT,
	@pow   FLOAT
)  
RETURNS FLOAT AS  
BEGIN
	DECLARE @x AS FLOAT
	SET @x = POWER(@arg1, @pow)
	RETURN @x
END