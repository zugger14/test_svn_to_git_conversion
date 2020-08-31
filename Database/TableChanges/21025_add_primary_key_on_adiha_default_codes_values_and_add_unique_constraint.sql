IF EXISTS(
	SELECT 1
	FROM sys.objects
	WHERE object_id = OBJECT_ID (N'[dbo].[PK_adiha_default_codes_values_1]') 
		AND parent_object_id = OBJECT_ID (N'[dbo].[adiha_default_codes_values]')
)
BEGIN
 	ALTER TABLE adiha_default_codes_values 
	DROP CONSTRAINT PK_adiha_default_codes_values_1
	PRINT 'Constraint Droppped';
END
ELSE
BEGIN
	PRINT 'Already Dropped'
END

IF COL_LENGTH('adiha_default_codes_values', 'adiha_default_codes_values_id') IS NULL
BEGIN
    ALTER TABLE adiha_default_codes_values ADD adiha_default_codes_values_id INT IDENTITY(1, 1) PRIMARY KEY
END
GO

IF NOT EXISTS( 
			SELECT 1
			FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
			INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
				AND tc.Constraint_name = ccu.Constraint_name    
				AND tc.CONSTRAINT_TYPE = 'UNIQUE'
				AND tc.Table_Name = 'adiha_default_codes_values'
				AND	tc.CONSTRAINT_NAME = 'UC_adiha_default_codes_values_code_id_var_value_seq_no'
)
BEGIN
	ALTER TABLE [dbo].adiha_default_codes_values 
	WITH NOCHECK ADD CONSTRAINT [UC_adiha_default_codes_values_code_id_var_value_seq_no] 
	UNIQUE (var_value, seq_no, default_code_id)
	PRINT 'Unique constraint added'
END
ELSE
BEGIN
	PRINT 'Already Added'
END

GO