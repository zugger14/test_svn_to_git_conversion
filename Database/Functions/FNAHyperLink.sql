IF OBJECT_ID(N'FNAHyperLink', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAHyperLink]
GO 

CREATE FUNCTION [dbo].[FNAHyperLink]
(
	@func_id        VARCHAR(50),
	@label          VARCHAR(500),
	@arg1           VARCHAR(50),
	@disable_hyper  VARCHAR(200)
)
RETURNS VARCHAR(500)
AS
BEGIN
	DECLARE @hyper_text VARCHAR(500)
	IF @disable_hyper = '-1'
SET  @hyper_text='<span style=cursor:hand onClick=openHyperLink('+@func_id+','+@arg1+')><font color=#0000ff><u>'+ @label +'</u></font></span>'
ELSE
SET  @hyper_text= @label 
RETURN @hyper_text
END