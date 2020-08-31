IF OBJECT_ID('[dbo].[vw_locale_mapping]') IS NOT NULL
    DROP VIEW [dbo].[vw_locale_mapping]
GO

/**
	Collects user specific translated language.
	
	Columns
	language_id			: Language ID of user.
	original_keyword	: Original text in English language.
	translated_keyword	: Translated text in user's language.
*/

CREATE VIEW [dbo].[vw_locale_mapping]
AS	
	SELECT lm.* 
	FROM application_users au
	INNER JOIN locale_mapping lm ON lm.language_id = ISNULL(au.[language],101600)
	WHERE au.user_login_id = dbo.FNADBUser()
	
GO