/****** Object:  UserDefinedFunction [dbo].[FNAContractVol]    Script Date: 05/02/2011 13:36:37 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAContractVol]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAContractVol]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAContractVol]    Script Date: 05/02/2011 13:36:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





--select dbo.FNAPeakDemand()

CREATE FUNCTION [dbo].[FNAContractVol] (@x int)
RETURNS float AS  
BEGIN 
	return 1
END






