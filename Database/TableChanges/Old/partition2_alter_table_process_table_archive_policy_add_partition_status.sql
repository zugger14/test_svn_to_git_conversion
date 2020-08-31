IF COL_LENGTH('process_table_archive_policy', 'partition_status') IS NULL

BEGIN
	ALTER TABLE process_table_archive_policy ADD partition_status BIT DEFAULT 0
	PRINT 'Column process_table_archive_policy.partition_status added.'
END
ELSE
BEGIN
	PRINT 'Column process_table_archive_policy.partition_status already exists.'
END
GO
