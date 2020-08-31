
IF COL_LENGTH('delete_source_deal_detail', 'delete_ts') IS NULL
BEGIN
	ALTER TABLE delete_source_deal_detail ADD delete_ts DATETIME
	
	PRINT 'Column delete_source_deal_detail.delete_ts added.'
END
ELSE
BEGIN
	PRINT 'Column delete_source_deal_detail.delete_ts already exists.'
END
GO


IF COL_LENGTH('delete_source_deal_detail', 'delete_user') IS NULL
BEGIN
	ALTER TABLE delete_source_deal_detail ADD delete_user VARCHAR(30)
	
	PRINT 'Column delete_source_deal_detail.delete_user added.'
END
ELSE
BEGIN
	PRINT 'Column delete_source_deal_detail.delete_user already exists.'
END
GO



IF COL_LENGTH('delete_source_deal_header', 'delete_ts') IS NULL
BEGIN
	ALTER TABLE delete_source_deal_header ADD delete_ts DATETIME
	
	PRINT 'Column delete_source_deal_header.delete_ts added.'
END
ELSE
BEGIN
	PRINT 'Column delete_source_deal_header.delete_ts already exists.'
END
GO


IF COL_LENGTH('delete_source_deal_header', 'delete_user') IS NULL
BEGIN
	ALTER TABLE delete_source_deal_header ADD delete_user VARCHAR(30)
	
	PRINT 'Column delete_source_deal_header.delete_user added.'
END
ELSE
BEGIN
	PRINT 'Column delete_source_deal_header.delete_user already exists.'
END
GO
