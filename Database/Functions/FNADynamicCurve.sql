
IF OBJECT_ID(N'FNADynamicCurve', N'FN') IS NOT NULL
DROP FUNCTION FNADynamicCurve
GO
CREATE FUNCTION [dbo].FNADynamicCurve(@x INT,@y INT)
RETURNS float AS  
BEGIN 
	return 1
END









