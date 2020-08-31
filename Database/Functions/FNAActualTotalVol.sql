/****** Object:  UserDefinedFunction [dbo].[FNAActualTotalVol]    Script Date: 01/11/2011 10:22:23 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAActualTotalVol]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAActualTotalVol]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAActualTotalVol]    Script Date: 01/11/2011 10:22:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAActualTotalVol]()

RETURNS FLOAT AS
BEGIN

	return 1
END






