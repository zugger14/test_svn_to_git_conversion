/****** Object:  UserDefinedFunction [dbo].[FNAMxRwValue]    Script Date: 05/02/2011 11:05:07 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAMxRwValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAMxRwValue]
/****** Object:  UserDefinedFunction [dbo].[FNAMxRwValue]    Script Date: 05/02/2011 11:05:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAMxRwValue](@row int,@no_month int)
RETURNS float AS  
BEGIN 
	return 1
END







