IF NOT EXISTS (SELECT 1 FROM adiha_default_codes WHERE default_code_id = 106)
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
	106,
	'collaterals_in_credit_exposure',
	'Collaterals in Credit Exposure',
	'Collaterals in Credit Exposure',
	'1'
	)    
    PRINT '106 INSERTED IN adiha_default_codes.'
END
ELSE
BEGIN
    PRINT '106 ALREADY EXISTS IN adiha_default_codes.'
END

IF NOT EXISTS (SELECT 1 FROM adiha_default_codes_values_possible WHERE default_code_id = 106)
BEGIN
	INSERT INTO adiha_default_codes_values_possible
	(
		default_code_id
		,var_value
		,[description]
	)
	VALUES
	(
		'106',
		'0',
		'Take only approved collateral'
	),
	(
		'106',
		'1',
		'Take unsecured collateral status'
	)
	PRINT '106 INSERTED IN adiha_default_codes_values_possible.'
END
ELSE
BEGIN
    PRINT '106 ALREADY EXISTS IN adiha_default_codes_values_possible.'
END

IF NOT EXISTS (SELECT 1 FROM adiha_default_codes_values WHERE default_code_id = 106)
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
		106,
		1,
		'1',
		'Take unsecured collateral status'
	)
	PRINT '106 INSERTED IN adiha_default_codes_values.'
END
ELSE
BEGIN
    PRINT '106 ALREADY EXISTS IN adiha_default_codes_values.'
END