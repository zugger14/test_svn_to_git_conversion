IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes 
	WHERE default_code_id = 204
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
	204
	, 'workflow_execution_mode'
	, 'Workflow Execution Mode'
	, 'Workflow Execution Mode'
	, '1'
)
END
ELSE
BEGIN
	PRINT 'Default Code Id 204 already EXISTS.'
END


IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes_values_possible
	WHERE default_code_id = 204
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
		204
		,'1'
		,'Run in queue'
	)
END
ELSE
BEGIN
	PRINT 'Default Code Id 204 with Var Value 1 already EXISTS.'
END

IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes_values_possible
	WHERE default_code_id = 204
	AND var_value = '0'
)
BEGIN
	INSERT INTO adiha_default_codes_values_possible 
	(
	default_code_id
	, var_value
	, description
	) 
	VALUES (
		204
		,'0'
		,'Run in parallel'
	)
END
ELSE
BEGIN
	PRINT 'Default Code Id 204 with Var Value 0 already EXISTS.'
END
