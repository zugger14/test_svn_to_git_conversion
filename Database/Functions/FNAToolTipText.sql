IF OBJECT_ID(N'FNAToolTipText', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAToolTipText]
GO 

CREATE FUNCTION [dbo].[FNAToolTipText]
(
	@label  VARCHAR(500),
	@tips   VARCHAR(5000)
)
RETURNS VARCHAR(5000)
AS
BEGIN
	DECLARE @hyper_text VARCHAR(5000)
	SET @hyper_text = '<span title=''' + @tips + '''><l>' + @label + 
	    '<l></span>'
	
	RETURN @hyper_text
END