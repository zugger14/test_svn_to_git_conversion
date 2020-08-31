

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'fas_link_header_audit' AND COLUMN_NAME = 'audit_id')
BEGIN
	ALTER TABLE fas_link_header_audit ADD audit_id INT IDENTITY(1,1)
	PRINT 'Added field audit_id'
END

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'fas_link_detail_audit' AND COLUMN_NAME = 'audit_id')
BEGIN
	ALTER TABLE fas_link_detail_audit ADD audit_id INT 
	PRINT 'Added field audit_id'
END

