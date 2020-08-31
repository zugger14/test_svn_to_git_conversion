IF OBJECT_ID('[dbo].[FNAHyperLinkTextComp9]', 'fn') IS NOT NULL
    DROP FUNCTION [dbo].[FNAHyperLinkTextComp9]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAHyperLinkTextComp9]
(
	@func_id  VARCHAR(50),
	@label    VARCHAR(500),
	@arg1     VARCHAR(50),
	@arg2     VARCHAR(50),
	@arg3     VARCHAR(50),
	@arg4     VARCHAR(50),
	@arg5     VARCHAR(50),
	@arg6     VARCHAR(50),
	@arg7     VARCHAR(50),
	@arg8     VARCHAR(10)
)
RETURNS VARCHAR(500)
AS
BEGIN
	DECLARE @hyper_text VARCHAR(500)
	
	SET @hyper_text = '<span style=cursor:hand onClick="parent.openHyperLinkMoreCompHierarchy(' + @func_id + ',' + @arg1 + ',''' + @arg2 + ''',''' + @arg3 + ''',''' + @arg4 + ''',''' + @arg5 + ''',''' + @arg6 + ''',''' + @arg7 + ''',''' + @arg8 + ''')"> <font color=#0000ff><u><l>' + @label + '<l></u></font></span>'	
	RETURN @hyper_text
END


