/****** Object:  UserDefinedFunction [dbo].[FNAEDRValue]    Script Date: 08/20/2009 12:25:20 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAEDRValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAEDRValue]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAEDRValue]    Script Date: 08/20/2009 12:25:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAEDRValue](@x int,@y int)
RETURNS float AS  
BEGIN 
	return 1
END






