/****** Object:  UserDefinedFunction [dbo].[FNAInterruptCalc]    Script Date: 05/02/2011 11:10:10 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAInterruptCalc]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAInterruptCalc]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAInterruptCalc]    Script Date: 05/02/2011 11:10:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--select dbo.FNAPeakDemand()

CREATE FUNCTION [dbo].[FNAInterruptCalc] (@x int, @y int)
RETURNS float AS  
BEGIN 
	return 1
END






