IF OBJECT_ID(N'[dbo].[spa_locales]', N'P') IS NOT NULL
  DROP PROCEDURE [dbo].spa_locales

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Gets the translated text to the selected language

	Parameters
	@language_id : Language selection
*/
CREATE PROCEDURE [dbo].spa_locales
	@language_id INT
AS

SET NOCOUNT ON

DECLARE @xml NVARCHAR(MAX) = NULL

-- u0027 is unicode character for singql quote (Replaced because DB Session didn't support it in session data)
SELECT @xml = ISNULL(@xml + ',', '') + '"' + 
				REPLACE(REPLACE(REPLACE(REPLACE(LOWER(original_keyword), CHAR(13) + CHAR(10), ' '), '\', '_u005c_'), '"', '_u0022_'), '''', '_u0027_') + '":"' + 
				REPLACE(REPLACE(REPLACE(REPLACE(translated_keyword, CHAR(13) + CHAR(10), ' '), '\', '_u005c_'), '"', '_u0022_'), '''', '_u0027_') + '"'
FROM locale_mapping
WHERE language_id = @language_id

SET @xml = '{' + ISNULL(@xml, '') + '}'

SELECT @xml lang_map