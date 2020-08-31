IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAPhoneFormat]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAPhoneFormat]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- modify date: 2018-07-11
-- Description: This Function Returns formated phone number for 10 digits number.(arai@pioneersolutionsglobal.com)

-- Params:
-- @phone_no VARCHAR(25)
-- Example : SELECT dbo.FNAPhoneFormat ('5461245632')
-- ===========================================================================================================

CREATE FUNCTION [dbo].[FNAPhoneFormat] (@phone_no VARCHAR(25))
RETURNS VARCHAR(25) AS

BEGIN	
	DECLARE @formated_no VARCHAR(25) 
	SET @phone_no = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@phone_no, '(', ''), ')', ''), '-', ''), ' ', ''), '  ','')));

	IF (LEN(@phone_no) <> 10)
		SET @formated_no = @phone_no
	ELSE
		SET @formated_no = '(' + SUBSTRING(@phone_no, 1, 3) + ') ' + SUBSTRING(@phone_no, 4, 3) + '-' + SUBSTRING(@phone_no, 7, 4)

	RETURN @formated_no
END