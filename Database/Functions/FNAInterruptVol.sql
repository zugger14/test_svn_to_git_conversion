/****** Object:  UserDefinedFunction [dbo].[FNAInterruptVol]    Script Date: 05/02/2011 11:23:20 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAInterruptVol]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAInterruptVol]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAInterruptVol]    Script Date: 05/02/2011 11:23:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create FUNCTION [dbo].[FNAInterruptVol] (@x int)
RETURNS float AS  
BEGIN 
	return 1
END


