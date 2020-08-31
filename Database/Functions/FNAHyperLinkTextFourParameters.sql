/****** Object:  function [dbo].[FNAHyperLinkTextFourParameters]    Script Date: 10/19/2008 11:49:38 ******/
IF EXISTS (
       SELECT *
       FROM   sys.objects
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[FNAHyperLinkTextFourParameters]')
              AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT')
   )
    DROP FUNCTION [dbo].[FNAHyperLinkTextFourParameters]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAHyperLinkTextFourParameters]
(
	@func_id  VARCHAR(50),
	@label    VARCHAR(500),
	@arg1     VARCHAR(50),
	@arg2     VARCHAR(50),
	@arg3     VARCHAR(50),
	@arg4     VARCHAR(50) = NULL
)
RETURNS VARCHAR(500)
AS
BEGIN
	DECLARE @hyper_text VARCHAR(500)
	
	SET @hyper_text = 
	    '<span style=cursor:hand onClick=parent.openHyperLinkMore(' + @func_id + 
	    ',' + @arg1 + ',''' + @arg2 + ''',''' + @arg3 + ''',''' + @arg4 + ''')><font color=#0000ff><u><l>' + @label + '<l></u></font></span>'
	
	RETURN @hyper_text
END
GO