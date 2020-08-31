IF COL_LENGTH('matching_detail_audit', 'header_audit_id') IS NULL
BEGIN
	ALTER TABLE matching_detail_audit ADD header_audit_id INT
	PRINT 'Column header_audit_id added successfully.'
END
ELSE
BEGIN
	PRINT 'Column header_audit_id already exist.'
END
GO