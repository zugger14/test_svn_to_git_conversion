IF NOT EXISTS (SELECT 1 FROM adiha_default_codes WHERE default_code_id = 43)
BEGIN
	INSERT INTO adiha_default_codes
	(
		default_code_id,
		default_code,
		code_description,
		code_def,
		instances
	)
	VALUES
	(
	43,
	'ssis_configurations',
	'SSIS Configurations',
	'SSIS Configurations',
	'1'
	)    
    PRINT '43 INSERTED IN adiha_default_codes.'
END
ELSE
BEGIN
    PRINT '43 ALREADY EXISTS IN adiha_default_codes.'
END

GO

IF NOT EXISTS (SELECT 1 FROM adiha_default_codes_params WHERE default_code_id = 43)
BEGIN
	INSERT INTO adiha_default_codes_params
	(
		seq_no,
		default_code_id,
		var_name,
		[type_id],
		var_length,
		value_type
	)
	VALUES
	(
		1,
		43,
		'SSIS Configurations',
		3,
		'NULL',
		'h'
	)
	PRINT '43 INSERTED IN adiha_default_codes_params.'
END
ELSE
BEGIN
	PRINT '43 ALREADY EXISTS IN adiha_default_codes_params.'
END
GO

IF NOT EXISTS (SELECT 1 FROM adiha_default_codes_values WHERE default_code_id = 43)
BEGIN
	INSERT INTO adiha_default_codes_values
	(
		instance_no,
		default_code_id,
		seq_no,
		var_value,
		[description]
	)
	VALUES
	(
		'1',
		43,
		1,
		'1',
		'SSIS Configurations'
	)
	PRINT '43 INSERTED IN adiha_default_codes_values.'
END
ELSE
BEGIN
    PRINT '43 ALREADY EXISTS IN adiha_default_codes_values.'
END
