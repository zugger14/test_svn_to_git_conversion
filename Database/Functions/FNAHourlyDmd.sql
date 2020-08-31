IF OBJECT_ID(N'FNAHourlyDmd', N'FN') IS NOT NULL
	DROP FUNCTION [dbo].[FNAHourlyDmd]
GO 

CREATE FUNCTION [dbo].[FNAHourlyDmd] ()
RETURNS float AS  
BEGIN 
	return 1
END








