/****** Object:  UserDefinedFunction [dbo].[FNARContractValue]    Script Date: 12/13/2010 20:35:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNADutchTOU]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNADutchTOU]
/****** Object:  UserDefinedFunction [dbo].[FNADutchTOU]    Script Date: 12/12/2010 10:51:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNADutchTOU]()
RETURNS FLOAT AS  
BEGIN 
	return 1
END
