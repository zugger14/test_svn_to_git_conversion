IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes 
	WHERE default_code_id = 215
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
	215
	, 'MTM, Credit Exposure, Price Curve retention period'
	, 'MTM, Credit Exposure, Price Curve retention period'
	, 'MTM, Credit Exposure, Price Curve retention period'
	, '1'
)
END
ELSE
BEGIN
	PRINT 'Default Code Id 215 already EXISTS.'
END

IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes_values_possible
	WHERE default_code_id = 215
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
		215
		,'7'
		,'7 days'
	)
END
ELSE
BEGIN
	PRINT 'Default Code Id 215 with Var Value 7 already EXISTS.'
END


IF NOT EXISTS (SELECT 1 FROM adiha_default_codes_values WHERE default_code_id = 215)
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
		215,
		1,
		'7',
		'Retention period to purge MTM, Credit Exposure, Price Curve data'
	)
	PRINT '215 INSERTED IN adiha_default_codes_values.'
END
ELSE
BEGIN
    PRINT '215 ALREADY EXISTS IN adiha_default_codes_values.'
END

