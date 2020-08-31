IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNACO2EmissionsValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNACO2EmissionsValue]
GO 


CREATE FUNCTION [dbo].[FNACO2EmissionsValue]()
RETURNS float AS  
BEGIN 
	return 1
END










