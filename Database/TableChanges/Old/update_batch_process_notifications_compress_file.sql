IF EXISTS (SELECT 1 FROM  batch_process_notifications  WHERE compress_file IS NULL) 
BEGIN
	UPDATE batch_process_notifications SET compress_file = 'n' WHERE compress_file IS NULL
END
ELSE
	PRINT 'No records found with null value.'
