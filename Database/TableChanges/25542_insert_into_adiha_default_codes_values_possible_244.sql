IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes_values_possible
	WHERE default_code_id = 209
	AND var_value = '209'
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
		,'209'
		,'Save settlement for all as of dates'
	)
END
ELSE
BEGIN
	PRINT 'Default Code Id 209 with Var Value 209 already EXISTS.'
END
