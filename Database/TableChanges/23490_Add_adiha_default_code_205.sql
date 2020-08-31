IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes 
	WHERE default_code_id = 205
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
	205
	, 'queue_log_retention_days'
	, 'Queue log retention days'
	, 'Queue log retention days'
	, '1'
)
END
ELSE
BEGIN
	PRINT 'Default Code Id 205 already EXISTS.'
END
