/****** Object:  UserDefinedFunction [dbo].[FNAExAnteVolume]    Script Date: 06/05/2009 17:30:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAExAnteVolume]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAExAnteVolume]
/****** Object:  UserDefinedFunction [dbo].[FNAExAnteVolume]    Script Date: 06/05/2009 17:30:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAExAnteVolume]()
RETURNS float AS  
BEGIN 
	return 1
END









