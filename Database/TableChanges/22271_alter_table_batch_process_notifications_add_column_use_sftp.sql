IF COL_LENGTH('batch_process_notifications', 'use_sftp') IS NULL
BEGIN
	ALTER TABLE batch_process_notifications
	ADD use_sftp BIT DEFAULT 0
END


