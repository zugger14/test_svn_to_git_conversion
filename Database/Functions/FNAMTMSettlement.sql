/****** Object:  UserDefinedFunction [dbo].[FNAMTMSettlement]    Script Date: 04/02/2009 17:40:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAMTMSettlement]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAMTMSettlement]
/****** Object:  UserDefinedFunction [dbo].[FNAMTMSettlement]    Script Date: 04/02/2009 17:40:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAMTMSettlement]()
RETURNS FLOAT AS  
BEGIN 
	return 1
END
