IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_counterparty' AND COLUMN_NAME = 'counterparty_contact_id')
BEGIN
	ALter table source_counterparty ADD counterparty_contact_id INT

END