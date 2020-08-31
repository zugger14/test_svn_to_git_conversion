IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[FNAEmailHyperlink]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAEmailHyperlink]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNAEmailHyperlink] (@email_address VARCHAR(MAX))
RETURNS VARCHAR(8000) AS  
BEGIN 
	DECLARE @email_hyperlink VARCHAR(8000)
	
	IF @email_address IS NOT NULL AND @email_address <> ''
		SET @email_hyperlink = '<a href="mailto:' + @email_address + '">' + @email_address + '</a>'
	ELSE
		SET @email_hyperlink = ''
			
	RETURN @email_hyperlink
END

GO
