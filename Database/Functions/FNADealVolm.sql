/****** Object:  UserDefinedFunction [dbo].[FNADealVolm]    Script Date: 12/07/2010 16:46:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNADealVolm]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNADealVolm]
/****** Object:  UserDefinedFunction [dbo].[FNADealVolm]    Script Date: 12/07/2010 16:47:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNADealVolm](@check_fixation BIT = 1)
RETURNS FLOAT AS  
BEGIN 
	RETURN 1

END
