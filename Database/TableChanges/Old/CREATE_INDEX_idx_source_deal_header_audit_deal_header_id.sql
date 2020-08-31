
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.source_deal_header_audit') AND name = N'idx_source_deal_header_audit_deal_header_id')
BEGIN
   CREATE  INDEX idx_source_deal_header_audit_deal_header_id ON dbo.source_deal_header_audit(source_deal_header_id)
   PRINT 'Index idx_source_deal_header_audit_deal_header_id created.'
END
ELSE
BEGIN
	PRINT 'Index idx_source_deal_header_audit_deal_header_id already exists.'
END
GO



IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.source_deal_detail_audit') AND name = N'idx_source_deal_detail_audit_deal_header_id')
BEGIN
   CREATE  INDEX idx_source_deal_detail_audit_deal_header_id ON dbo.source_deal_detail_audit(source_deal_header_id)
   PRINT 'Index idx_source_deal_detail_audit_deal_header_id created.'
END
ELSE
BEGIN
	PRINT 'Index idx_source_deal_detail_audit_deal_header_id already exists.'
END

