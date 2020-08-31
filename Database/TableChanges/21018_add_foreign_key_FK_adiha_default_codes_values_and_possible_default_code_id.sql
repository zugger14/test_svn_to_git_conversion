--existency check for creating foreign key
IF NOT EXISTS( 
	SELECT 1
	FROM sys.foreign_keys 
	WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[FK_adiha_default_codes_values_and_possible_default_code_id]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[adiha_default_codes_values_possible]')
)
BEGIN 
 	ALTER TABLE adiha_default_codes_values_possible 
	ADD CONSTRAINT FK_adiha_default_codes_values_and_possible_default_code_id
	FOREIGN KEY (default_code_id)
	REFERENCES adiha_default_codes (default_code_id)
	PRINT 'FK_adiha_default_codes_values_and_possible_default_code_id added'
END
ELSE
BEGIN
	PRINT 'FK_adiha_default_codes_values_and_possible_default_code_id already added'
END

GO