IF COL_LENGTH(N'general_assest_info_virtual_storage', 'source_counterparty_id') IS NULL
BEGIN
	ALTER TABLE general_assest_info_virtual_storage ADD source_counterparty_id INT

	PRINT 'Added column source_counterparty_id.'
END