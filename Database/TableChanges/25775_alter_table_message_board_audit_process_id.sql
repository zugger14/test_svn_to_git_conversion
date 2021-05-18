IF COL_LENGTH('message_board_audit', 'process_id') IS NOT NULL
BEGIN
	ALTER TABLE 
	/**
		Table : message_board_audit
		Column : process_id
	**/
	message_board_audit ALTER COLUMN process_id VARCHAR(100) NULL
END
