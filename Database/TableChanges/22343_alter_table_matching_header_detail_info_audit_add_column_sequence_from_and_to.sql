IF COL_LENGTH('matching_header_detail_info_audit', 'sequence_from') IS NULL
BEGIN
	ALTER TABLE dbo.matching_header_detail_info_audit ADD sequence_from INT, sequence_to INT, delivery_date DATE, transfer_status INT
	PRINT 'Columns are added.'
END
ELSE PRINT 'Columns are already exist.'