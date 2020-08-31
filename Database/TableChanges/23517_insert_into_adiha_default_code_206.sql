IF NOT EXISTS(
	SELECT 1 FROM adiha_default_codes 
	WHERE default_code_id = 206
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
	206
	, 'Scheduling Granularity'
	, 'Scheduling Granularity'
	, ''
	, '1'
)
END
ELSE
BEGIN
	PRINT 'Default Code Id 206 already EXISTS.'
END
