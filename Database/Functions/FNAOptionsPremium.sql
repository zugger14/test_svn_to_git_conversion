/****** Object:  UserDefinedFunction [dbo].[FNAOptionsPremium]    Script Date: 04/02/2009 17:39:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAOptionsPremium]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAOptionsPremium]
/****** Object:  UserDefinedFunction [dbo].[FNAOptionsPremium]    Script Date: 04/02/2009 17:39:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAOptionsPremium]()
RETURNS FLOAT AS  
BEGIN 
	return 1
END
