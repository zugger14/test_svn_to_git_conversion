/****** Object:  UserDefinedFunction [dbo].[FNAYrlySetVolm]    Script Date: 12/07/2010 16:46:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAYrlySetVolm]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAYrlySetVolm]
/****** Object:  UserDefinedFunction [dbo].[FNAYrlySetVolm]    Script Date: 12/07/2010 16:47:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAYrlySetVolm]()
RETURNS FLOAT AS  
BEGIN 
	return 1
END
