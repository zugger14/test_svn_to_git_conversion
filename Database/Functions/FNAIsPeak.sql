/****** Object:  UserDefinedFunction [dbo].[FNAIsPeak]    Script Date: 05/02/2011 10:58:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAIsPeak]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAIsPeak]
/****** Object:  UserDefinedFunction [dbo].[FNAIsPeak]    Script Date: 05/02/2011 10:58:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAIsPeak]()
RETURNS float AS  
BEGIN 
	return 1
END











