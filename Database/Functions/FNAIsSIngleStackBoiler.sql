
/****** Object:  UserDefinedFunction [dbo].[FNAIsSIngleStackBoiler]    Script Date: 08/20/2009 12:38:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAIsSIngleStackBoiler]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAIsSIngleStackBoiler]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go



CREATE FUNCTION [dbo].[FNAIsSIngleStackBoiler]()
RETURNS float AS  
BEGIN 
	return 1
END










