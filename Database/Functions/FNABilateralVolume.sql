/****** Object:  UserDefinedFunction [dbo].[FNABilateralVolume]    Script Date: 06/05/2009 17:29:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNABilateralVolume]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNABilateralVolume]
/****** Object:  UserDefinedFunction [dbo].[FNABilateralVolume]    Script Date: 06/05/2009 17:29:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNABilateralVolume]()
RETURNS float AS  
BEGIN 
	return 1
END









