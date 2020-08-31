SET NOCOUNT ON

IF OBJECT_ID(N'[dbo].FNAGetLocaleValue', N'FN') IS NOT NULL 
	DROP FUNCTION [dbo].FNAGetLocaleValue
GO

/**
	Generates locale translated text.

	Parameters
	@text	:	Original text.
*/

CREATE FUNCTION [dbo].[FNAGetLocaleValue]
(
	@text NVARCHAR(4000)
)
RETURNS NVARCHAR(4000)
AS
BEGIN
	DECLARE  @user_locale INT = NULL, @user_name NVARCHAR(200) = dbo.FNADBUser(), @locale_value NVARCHAR(4000) = NULL

	SELECT @user_locale = [language]
	FROM application_users
	WHERE user_login_id = @user_name
	
	IF @user_locale <> 101600 -- Other than English
	BEGIN
		SELECT @locale_value = translated_keyword
		FROM locale_mapping lm
		WHERE lm.original_keyword = @text AND language_id = @user_locale

		SET @locale_value = REPLACE(@locale_value, ',', '\,')
	END

	RETURN ISNULL(@locale_value, @text)
END
GO