IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'save_confirm_status' AND COLUMN_NAME = 'status')
BEGIN
	ALTER TABLE save_confirm_status add [status] CHAR(1)
END

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'save_confirm_status' AND COLUMN_NAME = 'source_deal_header_id')
BEGIN
	ALTER TABLE save_confirm_status add [source_deal_header_id] INT NULL
END
