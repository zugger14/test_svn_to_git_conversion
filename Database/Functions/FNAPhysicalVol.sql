IF OBJECT_ID(N'FNAPhysicalVol', N'FN') IS NOT NULL
DROP FUNCTION [dbo].FNAPhysicalVol
GO
CREATE FUNCTION [dbo].FNAPhysicalVol()
RETURNS float AS  
BEGIN 
	return 1
END









