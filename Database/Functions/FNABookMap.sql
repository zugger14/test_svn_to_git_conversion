/****** Object:  UserDefinedFunction [dbo].[FNABookMap]    Script Date: 01/11/2011 09:36:22 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNABookMap]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNABookMap]
GO
/****** Object:  UserDefinedFunction [dbo].[FNABookMap]    Script Date: 01/11/2011 09:35:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE FUNCTION [dbo].[FNABookMap] (@level int)
RETURNS INT AS  
BEGIN 
	return 1
END






