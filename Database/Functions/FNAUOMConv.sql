/****** Object:  UserDefinedFunction [dbo].[FNAUOMConv]    Script Date: 08/20/2009 12:30:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAUOMConv]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAUOMConv]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAUOMConv]    Script Date: 08/20/2009 12:30:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAUOMConv](@from_uom int,@to_uom int)
RETURNS float AS  
BEGIN 
	return 1
	
END




