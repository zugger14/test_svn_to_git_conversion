IF NOT EXISTS (SELECT 1 FROM adiha_default_codes WHERE default_code_id = 105)
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
	105,
	'unsecured_limit_in_credit_exposure',
	'Unsecured Limit in Credit Exposure',
	'Unsecured Limit in Credit Exposure',
	'1'
	)    
    PRINT '105 INSERTED IN adiha_default_codes.'
END
ELSE
BEGIN
    PRINT '105 ALREADY EXISTS IN adiha_default_codes.'
END

IF NOT EXISTS (SELECT 1 FROM adiha_default_codes_values_possible WHERE default_code_id = 105)
BEGIN
	INSERT INTO adiha_default_codes_values_possible
	(
		default_code_id
		,var_value
		,[description]
	)
	VALUES
	(
		'105',
		'0',
		'Take only approved unsecured limits'
	),
	(
		'105',
		'1',
		'Take unsecured limits status'
	)
	PRINT '105 INSERTED IN adiha_default_codes_values_possible.'
END
ELSE
BEGIN
    PRINT '105 ALREADY EXISTS IN adiha_default_codes_values_possible.'
END

IF NOT EXISTS (SELECT 1 FROM adiha_default_codes_values WHERE default_code_id = 105)
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
		105,
		1,
		'1',
		'Take unsecured limits status'
	)
	PRINT '105 INSERTED IN adiha_default_codes_values.'
END
ELSE
BEGIN
    PRINT '105 ALREADY EXISTS IN adiha_default_codes_values.'
END