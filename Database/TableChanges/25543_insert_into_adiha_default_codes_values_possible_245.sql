IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes_values_possible
	WHERE default_code_id = 209
	AND var_value = '210'
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
		,'210'
		,'Do not save settlement as of date less than Month End for settled months'
	)
END
ELSE
BEGIN
	PRINT 'Default Code Id 209 with Var Value 210 already EXISTS.'
END
