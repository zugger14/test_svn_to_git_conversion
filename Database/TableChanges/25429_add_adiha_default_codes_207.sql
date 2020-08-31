IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes 
	WHERE default_code_id = 207
)
BEGIN
INSERT INTO adiha_default_codes 
(
	default_code_id
	,default_code
	, code_def
	, code_description
	, instances
)
VALUES (
	207
	, 'include_exclude_zero_position_in_mtm'
	, 'Include/Exclude zero position in MTM'
	, 'Include/Exclude zero position for MW position in MTM'
	, '1'
)
END
ELSE
BEGIN
	PRINT 'Default Code Id 207 already EXISTS.'
END


IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes_values_possible
	WHERE default_code_id = 207
	AND var_value = '207'
)
BEGIN
	INSERT INTO adiha_default_codes_values_possible 
	(
	default_code_id
	, var_value
	, description
	) 
	VALUES (
		207
		,'207'
		,'Include 0 Position for MW Position in MTM'
	)
END
ELSE
BEGIN
	PRINT 'Default Code Id 207 with Var Value 207 already EXISTS.'
END


IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes_values_possible
	WHERE default_code_id = 207
	AND var_value = '208'
)
BEGIN
	INSERT INTO adiha_default_codes_values_possible 
	(
	default_code_id
	, var_value
	, description
	) 
	VALUES (
		207
		,'208'
		,'Exclude 0 Position for MW Position in MTM'
	)
END
ELSE
BEGIN
	PRINT 'Default Code Id 207 with Var Value 208 already EXISTS.'
END
