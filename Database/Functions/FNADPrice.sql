/****** Object:  UserDefinedFunction [dbo].[FNADPrice]    Script Date: 12/30/2008 11:44:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNADPrice]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNADPrice]

GO
CREATE FUNCTION [dbo].[FNADPrice]()
RETURNS float AS  
BEGIN 
	return 1
END




