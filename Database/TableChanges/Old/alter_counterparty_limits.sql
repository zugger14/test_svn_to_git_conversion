
IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'counterparty_limits' AND COLUMN_NAME = 'bucket_detail_id')
BEGIN
	ALTER TABLE counterparty_limits add [bucket_detail_id] INT NULL
END
