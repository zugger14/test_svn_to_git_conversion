/****** Object:  UserDefinedFunction [dbo].[FNADMTMChange]    Script Date: 12/07/2010 16:46:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNADMTMChange]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNADMTMChange]
/****** Object:  UserDefinedFunction [dbo].[FNADMTMChange]    Script Date: 12/07/2010 16:47:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNADMTMChange]()
RETURNS FLOAT AS  
BEGIN 
	return 1
END
