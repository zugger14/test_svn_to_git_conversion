/****** Object:  UserDefinedFunction [dbo].[FNAImbalanceVol]    Script Date: 11/10/2010 17:12:59 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAImbalanceTotalVol]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAImbalanceTotalVol]
/****** Object:  UserDefinedFunction [dbo].[FNAImbalanceTotalVol]    Script Date: 11/10/2010 17:13:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAImbalanceTotalVol]()
RETURNS float AS  
BEGIN 
	return 1
END

