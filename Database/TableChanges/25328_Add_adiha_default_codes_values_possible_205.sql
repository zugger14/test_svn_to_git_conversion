IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes_values_possible
	WHERE default_code_id = 205
	AND var_value = '1'
)
BEGIN
	INSERT INTO adiha_default_codes_values_possible 
	(
	default_code_id
	, var_value
	, description
	) 
	VALUES (
		205
		,'1'
		,'1 Day'
	)
END
ELSE
BEGIN
	PRINT 'Default Code Id 205 with Var Value 1 already EXISTS.'
END


IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes_values_possible
	WHERE default_code_id = 205
	AND var_value = '2'
)
BEGIN
	INSERT INTO adiha_default_codes_values_possible 
	(
	default_code_id
	, var_value
	, description
	) 
	VALUES (
		205
		,'2'
		,'2 Days'
	)
END
ELSE
BEGIN
	PRINT 'Default Code Id 205 with Var Value 2 already EXISTS.'
END


IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes_values_possible
	WHERE default_code_id = 205
	AND var_value = '3'
)
BEGIN
	INSERT INTO adiha_default_codes_values_possible 
	(
	default_code_id
	, var_value
	, description
	) 
	VALUES (
		205
		,'3'
		,'3 Days'
	)
END
ELSE
BEGIN
	PRINT 'Default Code Id 205 with Var Value 3 already EXISTS.'
END


IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes_values_possible
	WHERE default_code_id = 205
	AND var_value = '4'
)
BEGIN
	INSERT INTO adiha_default_codes_values_possible 
	(
	default_code_id
	, var_value
	, description
	) 
	VALUES (
		205
		,'4'
		,'4 Days'
	)
END
ELSE
BEGIN
	PRINT 'Default Code Id 205 with Var Value 4 already EXISTS.'
END


IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes_values_possible
	WHERE default_code_id = 205
	AND var_value = '5'
)
BEGIN
	INSERT INTO adiha_default_codes_values_possible 
	(
	default_code_id
	, var_value
	, description
	) 
	VALUES (
		205
		,'5'
		,'5 Days'
	)
END
ELSE
BEGIN
	PRINT 'Default Code Id 205 with Var Value 5 already EXISTS.'
END


IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes_values_possible
	WHERE default_code_id = 205
	AND var_value = '6'
)
BEGIN
	INSERT INTO adiha_default_codes_values_possible 
	(
	default_code_id
	, var_value
	, description
	) 
	VALUES (
		205
		,'6'
		,'6 Days'
	)
END
ELSE
BEGIN
	PRINT 'Default Code Id 205 with Var Value 6 already EXISTS.'
END


IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes_values_possible
	WHERE default_code_id = 205
	AND var_value = '7'
)
BEGIN
	INSERT INTO adiha_default_codes_values_possible 
	(
	default_code_id
	, var_value
	, description
	) 
	VALUES (
		205
		,'7'
		,'7 Days'
	)
END
ELSE
BEGIN
	PRINT 'Default Code Id 205 with Var Value 7 already EXISTS.'
END
