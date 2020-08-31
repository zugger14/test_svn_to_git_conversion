IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'adiha_default_codes_values'
		AND COLUMN_NAME IN ('adiha_default_codes_values_id','var_value')
)
BEGIN
	UPDATE adiha_default_codes_values SET var_value = 0 
	WHERE adiha_default_codes_values_id = 1600

END
