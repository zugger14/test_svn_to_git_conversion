/****** Object:  UserDefinedFunction [dbo].[FNASO2EmissionsValue]    Script Date: 08/20/2009 12:30:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNASO2EmissionsValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNASO2EmissionsValue]
GO
/****** Object:  UserDefinedFunction [dbo].[FNASO2EmissionsValue]    Script Date: 08/20/2009 12:30:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNASO2EmissionsValue]()
RETURNS float AS  
BEGIN 
	return 1
END









