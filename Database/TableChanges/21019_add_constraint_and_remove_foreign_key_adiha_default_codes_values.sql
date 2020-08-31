IF EXISTS(
		SELECT 1
		FROM sys.foreign_keys 
		WHERE object_id = OBJECT_ID(N'[dbo].[FK_adiha_default_codes_values_default_code_id_var_value]') 
			AND parent_object_id = OBJECT_ID(N'[dbo].[adiha_default_codes_values]')
)
BEGIN
 	ALTER TABLE adiha_default_codes_values 
	DROP CONSTRAINT FK_adiha_default_codes_values_default_code_id_var_value
	PRINT 'Constraint Dropped.'
END
ELSE
BEGIN
	PRINT 'Already deleted'
END

IF NOT EXISTS(
			SELECT 1
			FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
			INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
			ON tc.TABLE_NAME = ccu.TABLE_NAME
				AND tc.Constraint_name = ccu.Constraint_name    
				AND tc.CONSTRAINT_TYPE = 'CHECK'
				AND tc.Table_Name = 'adiha_default_codes_values'
				AND	tc.CONSTRAINT_NAME = 'chk_value_exists'
)
BEGIN
	ALTER TABLE adiha_default_codes_values 
	ADD CONSTRAINT chk_value_exists 
	CHECK (dbo.FNACheckDefaultCodeValue(default_code_id, var_value) = 1)
	PRINT 'Constraint Added'
END
ELSE
BEGIN
	PRINT 'Constraint Exists'
END

GO