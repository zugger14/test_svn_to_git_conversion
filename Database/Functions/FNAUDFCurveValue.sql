/****** Object:  UserDefinedFunction [dbo].[FNAUDFValue]    Script Date: 07/23/2009 01:11:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAUDFCurveValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAUDFCurveValue]
/****** Object:  UserDefinedFunction [dbo].[FNAUDFValue]    Script Date: 07/23/2009 01:12:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAUDFCurveValue](@x INT)
RETURNS FLOAT AS  
BEGIN 
	return 1
END
