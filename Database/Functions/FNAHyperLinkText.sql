IF OBJECT_ID(N'FNAHyperLinkText', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAHyperLinkText]
GO 

CREATE FUNCTION [dbo].[FNAHyperLinkText]
(
	@func_id  VARCHAR(50),
	@label    VARCHAR(500),
	@arg1     VARCHAR(50)
)
RETURNS VARCHAR(500)
AS
BEGIN
	DECLARE @hyper_text VARCHAR(500)
SET  @hyper_text='<span style=cursor:hand onClick=openHyperLink('+@func_id+','+@arg1+')><font color=#0000ff><u>'+ @label +'</u></font></span>'
RETURN @hyper_text
END

















