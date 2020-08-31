
IF COL_LENGTH('eod_process_status', 'message_detail') IS NULL
BEGIN
	ALTER TABLE eod_process_status ADD message_detail VARCHAR(1000)
	PRINT 'Column eod_process_status.message_detail added.'
END
ELSE
BEGIN
	PRINT 'Column eod_process_status.message_detail already exists.'
END
GO

