

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'fas_link_detail_audit' AND COLUMN_NAME = 'auto_update')
BEGIN
	ALTER TABLE fas_link_detail_audit ADD auto_update CHAR(1)
	PRINT 'Added auto_update field'
END
