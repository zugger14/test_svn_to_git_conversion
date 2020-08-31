
/****** Object:  UserDefinedFunction [dbo].[FNAHyperLinkText3test]    Script Date: 04/15/2009 19:34:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAHyperLinkText3test]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAHyperLinkText3test]

/****** Object:  UserDefinedFunction [dbo].[FNAHyperLinkText3test]    Script Date: 04/15/2009 19:34:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[FNAHyperLinkText3test](@func_id VARCHAR(50),@label VARCHAR(500),@arg1 VARCHAR(50),@arg2 VARCHAR(500))
RETURNS VARCHAR(500) AS
BEGIN
	DECLARE @hyper_text VARCHAR(500)

	SET @hyper_text='<span style=cursor:hand onClick=parent.openHyperlinktest('+@func_id+','+@arg1+','''+@arg2+''')><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'

	RETURN @hyper_text
END	