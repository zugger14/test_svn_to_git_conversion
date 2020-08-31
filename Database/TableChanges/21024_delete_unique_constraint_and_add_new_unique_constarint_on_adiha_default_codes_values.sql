IF EXISTS( 
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
	DROP CONSTRAINT [UC_adiha_default_codes_values_code_id_var_value_seq_no]
	PRINT 'Unique constraint deleted'
END
ELSE
BEGIN
	PRINT 'Already Deleted'
END

IF NOT EXISTS( 
	SELECT 1
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
	INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
		AND tc.Constraint_name = ccu.Constraint_name    
        AND tc.CONSTRAINT_TYPE = 'UNIQUE'
        AND tc.Table_Name = 'adiha_default_codes_values'
		AND	tc.CONSTRAINT_NAME = 'UC_adiha_default_codes_values_code_id_instance_no_seq_no'
)
BEGIN
	ALTER TABLE [dbo].adiha_default_codes_values WITH NOCHECK 
	ADD CONSTRAINT [UC_adiha_default_codes_values_code_id_instance_no_seq_no] UNIQUE (default_code_id, instance_no, seq_no)
	PRINT 'Unique constraint added'
END
ELSE
BEGIN
	PRINT 'Already Added'
END

GO