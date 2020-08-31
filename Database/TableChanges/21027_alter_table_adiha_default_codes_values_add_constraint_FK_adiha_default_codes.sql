IF NOT EXISTS(SELECT 1
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
	INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
		AND tc.Constraint_name = ccu.Constraint_name    
		AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
		AND   tc.Table_Name = 'adiha_default_codes_values'
		AND ccu.COLUMN_NAME = 'default_code_id'
)
BEGIN
	ALTER TABLE [dbo].[adiha_default_codes_values] WITH NOCHECK ADD CONSTRAINT [FK_adiha_default_codes_default_code_id] FOREIGN KEY([default_code_id])
	REFERENCES [dbo].[adiha_default_codes] ([default_code_id])
	PRINT 'FK_adiha_default_codes_default_code_id added'
END
ELSE
BEGIN
	PRINT 'FK_adiha_default_codes_default_code_id already exist'
END