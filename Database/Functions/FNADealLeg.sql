/****** Object:  UserDefinedFunction [dbo].[FNADealLeg]    Script Date: 04/07/2009 17:17:04 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNADealLeg]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNADealLeg]
/****** Object:  UserDefinedFunction [dbo].[FNADealLeg]    Script Date: 04/07/2009 17:17:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNADealLeg]()
RETURNS FLOAT AS  
BEGIN 
	return 1
END
