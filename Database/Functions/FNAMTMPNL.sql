
/****** Object:  UserDefinedFunction [dbo].[FNAMTMPNL]    Script Date: 12/30/2008 11:44:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAMTMPNL]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAMTMPNL]


GO
/****** Object:  UserDefinedFunction [dbo].[FNAMTMPNL]    Script Date: 12/29/2008 19:38:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAMTMPNL]()
RETURNS FLOAT AS  
BEGIN 
	return 1
END
