/****** Object:  UserDefinedFunction [dbo].[FNAEMSConv]    Script Date: 08/20/2009 12:26:52 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAEMSConv]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAEMSConv]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAEMSConv]    Script Date: 08/20/2009 12:26:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAEMSConv] (@a as int,@b as int,@c as int,@d as int,@e as int)
RETURNS float AS  
BEGIN 
	
	return 1
END








