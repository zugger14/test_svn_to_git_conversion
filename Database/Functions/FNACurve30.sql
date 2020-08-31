/****** Object:  UserDefinedFunction [dbo].[FNACurve30]    Script Date: 02/14/2011 15:43:44 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNACurve30]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNACurve30]
GO

/****** Object:  UserDefinedFunction [dbo].[FNACurve30]    Script Date: 02/14/2011 15:43:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNACurve30] (@curve_id int, @volume_mult float)
RETURNS float AS  
BEGIN 
	return 1
END







GO


