IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes 
	WHERE default_code_id = 209
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
	209
	, 'save_settlement_data'
	, 'Save Settlement Data'
	, 'Save Settlement Data'
	, '1'
)
END
ELSE
BEGIN
	PRINT 'Default Code Id 209 already EXISTS.'
END
