/****** Object:  UserDefinedFunction [dbo].[FNACurve15]    Script Date: 02/14/2011 15:43:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNACurve15]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNACurve15]
GO


/****** Object:  UserDefinedFunction [dbo].[FNACurve15]    Script Date: 02/14/2011 15:43:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNACurve15] (@curve_id VARCHAR(100), @volume_mult float)
RETURNS float AS  
BEGIN 
	return 1
END

GO


