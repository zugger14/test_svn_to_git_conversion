/****** Object:  UserDefinedFunction [dbo].[FNAImbalanceVol]    Script Date: 11/10/2010 17:12:59 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNALocationVol]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNALocationVol]
/****** Object:  UserDefinedFunction [dbo].[FNAImbalanceVol]    Script Date: 11/10/2010 17:13:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNALocationVol]()
RETURNS float AS  
BEGIN 
	return 1
END

