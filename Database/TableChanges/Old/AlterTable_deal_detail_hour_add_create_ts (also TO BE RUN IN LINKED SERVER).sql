/*
* This script should be run in following databases:
* 1. Main db (e.g. TRMTracker_Essent).
* 2. Archive db (mentioned in process_table_archive_policy table, e.g. FarrmsData.adiha_process_archive_clean)
* That's why existence check is done for both table and column, as the archived db may not contain all the tables.
*/
IF OBJECT_ID(N'deal_detail_hour', N'U') IS NOT NULL AND COL_LENGTH('deal_detail_hour', 'create_ts') IS NULL
BEGIN
	ALTER TABLE deal_detail_hour ADD create_ts DATETIME DEFAULT GETDATE()
	PRINT 'Column deal_detail_hour(create_ts) added.'
END
ELSE
BEGIN
	PRINT 'Column deal_detail_hour(create_ts) already exists.'
END

IF OBJECT_ID(N'deal_detail_hour_arch1', N'U') IS NOT NULL AND COL_LENGTH('deal_detail_hour_arch1', 'create_ts') IS NULL
BEGIN
	ALTER TABLE deal_detail_hour_arch1 ADD create_ts DATETIME DEFAULT GETDATE()
	PRINT 'Column deal_detail_hour_arch1(create_ts) added.'
END
ELSE
BEGIN
	PRINT 'Column deal_detail_hour_arch1(create_ts) already exists.'
END

IF OBJECT_ID(N'deal_detail_hour_arch2', N'U') IS NOT NULL AND COL_LENGTH('deal_detail_hour_arch2', 'create_ts') IS NULL
BEGIN
	ALTER TABLE deal_detail_hour_arch2 ADD create_ts DATETIME DEFAULT GETDATE()
	PRINT 'Column deal_detail_hour_arch2(create_ts) added.'
END
ELSE
BEGIN
	PRINT 'Column deal_detail_hour_arch2(create_ts) already exists.'
END
GO

