IF OBJECT_ID(N'batch_process_notifications', N'U') IS NOT NULL AND COL_LENGTH('batch_process_notifications', 'batch_type') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		batch_type : Batch Type
	*/
		batch_process_notifications ADD batch_type NVARCHAR(10)
END
GO




