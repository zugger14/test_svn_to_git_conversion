IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'save_confirm_status' AND COLUMN_NAME = 'init_template')
BEGIN
	ALTER TABLE save_confirm_status ADD init_template VARCHAR(100)
END

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'save_confirm_status' AND COLUMN_NAME = 'sub_template')
BEGIN
	ALTER TABLE save_confirm_status ADD sub_template VARCHAR(100)
END

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'save_confirm_status' AND COLUMN_NAME = 'curve_definition')
BEGIN
	ALTER TABLE save_confirm_status ADD curve_definition VARCHAR(MAX)
END
