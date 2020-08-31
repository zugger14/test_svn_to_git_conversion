IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes_values_possible
	WHERE default_code_id = 206
	AND var_value = '981'
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
		,'981'
		,'Daily'
	)
END
ELSE
BEGIN
	PRINT 'Default Code Id 206 with Var Value 981 already EXISTS.'
END
