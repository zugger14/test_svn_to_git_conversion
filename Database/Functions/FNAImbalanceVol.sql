/****** Object:  UserDefinedFunction [dbo].[FNAImbalanceVol]    Script Date: 11/10/2010 17:12:59 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAImbalanceVol]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAImbalanceVol]
/****** Object:  UserDefinedFunction [dbo].[FNAImbalanceVol]    Script Date: 11/10/2010 17:13:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAImbalanceVol]()
RETURNS float AS  
BEGIN 
	return 1
END

