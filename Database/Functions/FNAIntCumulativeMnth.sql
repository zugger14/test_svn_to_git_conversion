/****** Object:  UserDefinedFunction [dbo].[FNAIntCumulativeMnth]    Script Date: 05/02/2011 11:33:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAIntCumulativeMnth]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAIntCumulativeMnth]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAIntCumulativeMnth]    Script Date: 05/02/2011 11:34:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[FNAIntCumulativeMnth] ()
RETURNS float AS  
BEGIN 
	return 1
END








