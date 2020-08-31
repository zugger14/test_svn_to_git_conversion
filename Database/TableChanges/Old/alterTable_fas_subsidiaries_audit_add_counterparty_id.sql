IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'fas_subsidiaries_audit' AND COLUMN_NAME = 'counterparty_id')
BEGIN
	ALter table fas_subsidiaries_audit ADD counterparty_id INT

END