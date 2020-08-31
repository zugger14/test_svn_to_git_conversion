/****** Object:  UserDefinedFunction [dbo].[FNAHyperLinkTextComp3]    Script Date: 04/15/2009 19:32:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAHyperLinkTextComp3]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAHyperLinkTextComp3]
/****** Object:  UserDefinedFunction [dbo].[FNAHyperLinkTextComp3]    Script Date: 04/15/2009 19:32:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[FNAHyperLinkTextComp3](@func_id VARCHAR(50),@label VARCHAR(500),@arg1 VARCHAR(50),@arg2 VARCHAR(500),@arg3 VARCHAR(500))
RETURNS VARCHAR(500) AS
BEGIN
	DECLARE @hyper_text VARCHAR(500)

	SET @hyper_text='<span style=cursor:hand onClick=openHyperLinkMore('+@func_id+','+@arg1+','''+@arg2+''','''+@arg3+''')><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'

	RETURN @hyper_text
END	



