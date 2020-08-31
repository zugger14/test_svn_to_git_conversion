

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'gen_fas_link_header' AND COLUMN_NAME = 'approved_process_id')
BEGIN
	ALTER TABLE gen_fas_link_header ADD approved_process_id VARCHAR(50)
END

