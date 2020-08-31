IF COL_LENGTH('process_queue','execution_start_ts') IS NULL 
	ALTER TABLE process_queue ADD execution_start_ts DATETIME
GO

IF COL_LENGTH('process_queue','execution_complete_ts') IS NULL 
	ALTER TABLE process_queue ADD execution_complete_ts DATETIME
GO