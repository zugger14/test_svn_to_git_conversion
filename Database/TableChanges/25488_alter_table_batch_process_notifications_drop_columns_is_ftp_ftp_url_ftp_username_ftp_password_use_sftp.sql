-- Dropping Default constraint ascociated with is_ftp, use_sftp columns
DECLARE @default_cosntraint_name NVARCHAR(MAX)
SELECT @default_cosntraint_name = d.NAME 
FROM   sys.all_columns c 
       JOIN sys.tables t ON t.object_id = c.object_id 
       JOIN sys.schemas s ON s.schema_id = t.schema_id 
       JOIN sys.default_constraints d ON c.default_object_id = d.object_id 
WHERE  t.NAME = 'batch_process_notifications' 
       AND c.NAME = 'use_sftp' 
       AND s.NAME = 'dbo'

IF @default_cosntraint_name IS NOT NULL
BEGIN 
	EXEC('ALTER TABLE batch_process_notifications DROP ' + @default_cosntraint_name)
END

SELECT @default_cosntraint_name = d.NAME 
FROM   sys.all_columns c 
       JOIN sys.tables t ON t.object_id = c.object_id 
       JOIN sys.schemas s ON s.schema_id = t.schema_id 
       JOIN sys.default_constraints d ON c.default_object_id = d.object_id 
WHERE  t.NAME = 'batch_process_notifications' 
       AND c.NAME = 'is_ftp' 
       AND s.NAME = 'dbo'

IF @default_cosntraint_name IS NOT NULL
BEGIN 
	EXEC('ALTER TABLE batch_process_notifications DROP ' + @default_cosntraint_name)
END

IF COL_LENGTH('batch_process_notifications', 'is_ftp') IS NOT NULL
	ALTER TABLE batch_process_notifications DROP COLUMN is_ftp 
GO
IF COL_LENGTH('batch_process_notifications', 'ftp_url') IS NOT NULL
	ALTER TABLE batch_process_notifications DROP COLUMN ftp_url 
GO
IF COL_LENGTH('batch_process_notifications', 'ftp_username') IS NOT NULL
	ALTER TABLE batch_process_notifications DROP COLUMN ftp_username 
GO
IF COL_LENGTH('batch_process_notifications', 'ftp_password') IS NOT NULL
	ALTER TABLE batch_process_notifications DROP COLUMN ftp_password 
GO
IF COL_LENGTH('batch_process_notifications', 'use_sftp') IS NOT NULL
	ALTER TABLE batch_process_notifications DROP COLUMN use_sftp 
GO
