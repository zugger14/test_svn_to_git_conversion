IF OBJECT_ID(N'batch_process_notifications', N'U') IS NOT NULL AND COL_LENGTH('batch_process_notifications', 'file_transfer_endpoint_id') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		file_transfer_endpoint_id : File transfer endpoint id
	*/
		batch_process_notifications ADD file_transfer_endpoint_id INT
END
GO

IF NOT EXISTS(SELECT 1
                  FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
                  INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                        AND tc.Constraint_name = ccu.Constraint_name   
                        AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                        AND   tc.Table_Name = 'batch_process_notifications'      --table name
                        AND ccu.COLUMN_NAME = 'file_transfer_endpoint_id'          --column name where FK constaint is to be created
)
BEGIN
       ALTER TABLE dbo.batch_process_notifications WITH NOCHECK ADD CONSTRAINT FK_file_transfer_endpoint_id FOREIGN KEY(file_transfer_endpoint_id)
		REFERENCES dbo.file_transfer_endpoint (file_transfer_endpoint_id) ON DELETE CASCADE
END
GO
