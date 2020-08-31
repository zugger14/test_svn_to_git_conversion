/****** Object:  UserDefinedFunction [dbo].[FNAGetCurveValue]    Script Date: 02/14/2011 15:43:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAGetCurveValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAGetCurveValue]
GO


/****** Object:  UserDefinedFunction [dbo].[FNAGetCurveValue]    Script Date: 02/14/2011 15:43:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNAGetCurveValue] (@curve_id VARCHAR(100))
RETURNS float AS  
BEGIN 
	return 1
END

GO


