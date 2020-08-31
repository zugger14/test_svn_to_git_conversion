IF OBJECT_ID(N'dbo.locale_mapping', N'U') IS NULL
BEGIN
	CREATE TABLE dbo.locale_mapping
	/**
		Keywords lanaguage translation mapping table.
	
		Columns
		language_id			: Language id.
		original_keyword	: Original text in English language.
		translated_keyword	: Translated text in other language.
	*/
	(
		language_id			INT,
		original_keyword	NVARCHAR(250),
		translated_keyword	NVARCHAR(250),
		CONSTRAINT [PK_locale_mapping] PRIMARY KEY CLUSTERED(language_id, original_keyword),
		CONSTRAINT [FK_locale_mapping_static_data_value] FOREIGN KEY(language_id) REFERENCES static_data_value(value_id)
	)

	PRINT 'Table ''locale_mapping'' is created.'
END
ELSE
BEGIN
	PRINT 'Table ''locale_mapping'' already exists.'
END