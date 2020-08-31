IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes 
	WHERE default_code_id = 203
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
	203
	, 'import_process_queue'
	, 'Enable the import process to execute on queue.'
	, 'Enable the import process to execute on queue.'
	, '1'
)
END
ELSE
BEGIN
	PRINT 'Default Code Id 203 already EXISTS.'
END


IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes_values_possible
	WHERE default_code_id = 203
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
		203
		,'0'
		,'Disble import process on queue'
	)
END
ELSE
BEGIN
	PRINT 'Default Code Id 203 with Var Value 0 already EXISTS.'
END


IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes_values_possible
	WHERE default_code_id = 203
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
		203
		,'1'
		,'Enable import process on queue'
	)
END
ELSE
BEGIN
	PRINT 'Default Code Id 203 with Var Value 1 already EXISTS.'
END


UPDATE adiha_default_codes 
SET [default_code] = 'import_execution_mode'
	, [code_def] = 'Import Execution Mode'
	, [code_description] = 'Import Execution Mode' 
WHERE default_code_id = 203

UPDATE adiha_default_codes_values_possible 
SET [var_value] = '0'
	, [description] = 'Run in queue'
WHERE default_code_id = 203 
AND var_value = '0'

UPDATE adiha_default_codes_values_possible 
SET [var_value] = '1'
	, [description] = 'Run in parallel'
WHERE default_code_id = 203 
AND var_value = '1'