/****** Object:  UserDefinedFunction [dbo].[FNACVD]    Script Date: 05/02/2011 11:15:44 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNACVD]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNACVD]
GO
/****** Object:  UserDefinedFunction [dbo].[FNACVD]    Script Date: 05/02/2011 11:15:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--select dbo.FNAPeakDemand()

CREATE FUNCTION [dbo].[FNACVD] (@x int,@ int)
RETURNS float AS  
BEGIN 
	return 1
END


