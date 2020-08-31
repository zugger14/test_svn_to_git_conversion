IF COL_LENGTH('process_queue','queue_sql') IS NOT NULL 
	ALTER TABLE process_queue ALTER COLUMN queue_sql NVARCHAR(MAX)
GO

IF COL_LENGTH('process_queue','process_id') IS NOT NULL 
	ALTER TABLE process_queue ALTER COLUMN process_id NVARCHAR(100)
GO

IF COL_LENGTH('process_queue','description') IS NOT NULL 
	ALTER TABLE process_queue ALTER COLUMN description NVARCHAR(MAX)
GO

IF COL_LENGTH('process_queue','error_description') IS NOT NULL 
	ALTER TABLE process_queue ALTER COLUMN error_description NVARCHAR(MAX)
GO

--IF COL_LENGTH('process_queue','create_user') IS NOT NULL 
--	ALTER TABLE process_queue ALTER COLUMN create_user NVARCHAR(50)
--GO

IF COL_LENGTH('process_queue','update_user') IS NOT NULL 
	ALTER TABLE process_queue ALTER COLUMN update_user NVARCHAR(50)
GO