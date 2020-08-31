IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes_values_possible
	WHERE default_code_id = 206
	AND var_value = '982'
)
BEGIN
	INSERT INTO adiha_default_codes_values_possible 
	(
	default_code_id
	, var_value
	, description
	) 
	VALUES (
		206
		,'982'
		,'Hourly'
	)
END
ELSE
BEGIN
	PRINT 'Default Code Id 206 with Var Value 982 already EXISTS.'
END
