/****** Object:  UserDefinedFunction [dbo].[FNAIntStartMnth]    Script Date: 05/02/2011 11:36:16 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAIntStartMnth]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAIntStartMnth]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAIntStartMnth]    Script Date: 05/02/2011 11:36:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[FNAIntStartMnth] ()
RETURNS float AS  
BEGIN 
	return 1
END








