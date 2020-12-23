IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes 
	WHERE default_code_id = 212
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
	212
	, 'storage_wacog_option'
	, 'Storage WACOG Option'
	, 'Storage WACOG Option'
	, '1'
)
END
ELSE
BEGIN
	PRINT 'Default Code Id 212 already EXISTS.'
END
GO

IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes_values_possible
	WHERE default_code_id = 212
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
		212
		,'1'
		,'Inventory Based'
	)
END
ELSE
BEGIN
	PRINT 'Default Code Id 212 with Var Value 1 already EXISTS.'
END
GO

IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes_values_possible
	WHERE default_code_id = 212
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
		212
		,'2'
		,'Injection Based'
	)
END
ELSE
BEGIN
	PRINT 'Default Code Id 212 with Var Value 2 already EXISTS.'
END
GO

IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes_values_possible
	WHERE default_code_id = 212
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
		212
		,'3'
		,'Inventory Based excluding prior day Withdrawal'
	)
END
ELSE
BEGIN
	PRINT 'Default Code Id 212 with Var Value 3 already EXISTS.'
END
GO
