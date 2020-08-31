IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'confirm_status_recent' AND COLUMN_NAME = 'is_confirm')
BEGIN
	ALTER TABLE confirm_status_recent add [is_confirm] CHAR(1)
END
