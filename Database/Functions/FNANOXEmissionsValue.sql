/****** Object:  UserDefinedFunction [dbo].[FNANOXEmissionsValue]    Script Date: 08/20/2009 12:33:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNANOXEmissionsValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNANOXEmissionsValue]
GO
/****** Object:  UserDefinedFunction [dbo].[FNANOXEmissionsValue]    Script Date: 08/20/2009 12:32:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNANOXEmissionsValue]()
RETURNS float AS  
BEGIN 
	return 1
END









