IF EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'contract_group' AND  COLUMN_NAME = 'is_lock')
BEGIN
	PRINT 'is_lock Already exists'
END
ELSE
BEGIN
	ALTER TABLE contract_group ADD [is_lock] char
END