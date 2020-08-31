IF COL_LENGTH('source_deal_detail', 'delivery_date') IS NULL
BEGIN
	ALTER TABLE source_deal_detail
	ADD delivery_date DATETIME
	PRINT 'Column ''delivery_date'' added.'
END
ELSE PRINT 'Column ''delivery_date'' already exists.'
GO

IF COL_LENGTH('source_deal_detail_template', 'delivery_date') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template
	ADD delivery_date DATETIME
	PRINT 'Column ''delivery_date'' added.'
END
ELSE PRINT 'Column ''delivery_date'' already exists.'
GO

IF COL_LENGTH('source_deal_detail_audit', 'delivery_date') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_audit
	ADD delivery_date DATETIME
	PRINT 'Column ''delivery_date'' added.'
END
ELSE PRINT 'Column ''delivery_date'' already exists.'
GO

IF COL_LENGTH('delete_source_deal_detail', 'delivery_date') IS NULL
BEGIN
	ALTER TABLE delete_source_deal_detail
	ADD delivery_date DATETIME
	PRINT 'Column ''delivery_date'' added.'
END
ELSE PRINT 'Column ''delivery_date'' already exists.'
GO


