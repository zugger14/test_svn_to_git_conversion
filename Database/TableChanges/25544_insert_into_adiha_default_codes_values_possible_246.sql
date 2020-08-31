IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes_values_possible
	WHERE default_code_id = 209
	AND var_value = '211'
)
BEGIN
	INSERT INTO adiha_default_codes_values_possible 
	(
	default_code_id
	, var_value
	, description
	) 
	VALUES (
		209
		,'211'
		,'Do not save settlement as of date less than Month End and Current Date'
	)
END
ELSE
BEGIN
	PRINT 'Default Code Id 209 with Var Value 211 already EXISTS.'
END
