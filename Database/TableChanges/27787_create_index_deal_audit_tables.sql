IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_header_audit]') 
					AND name = N'IDX_source_deal_header_audit')
 
BEGIN
     CREATE INDEX [IDX_source_deal_header_audit] ON [dbo].[source_deal_header_audit] (source_deal_header_id, audit_id)
END
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_detail_audit]') 
					AND name = N'IDX_source_deal_detail_audit')
 
BEGIN
     CREATE INDEX [IDX_source_deal_detail_audit] ON [dbo].[source_deal_detail_audit] (source_deal_header_id, source_deal_detail_id, audit_id, header_audit_id)
END
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[user_defined_deal_fields_audit]') 
					AND name = N'IDX_user_defined_deal_fields_audit')
 
BEGIN
     CREATE INDEX [IDX_user_defined_deal_fields_audit] ON [dbo].[user_defined_deal_fields_audit] (source_deal_header_id, udf_template_id, header_audit_id)
END
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[user_defined_deal_detail_fields_audit]') 
					AND name = N'IDX_user_defined_deal_detail_fields_audit')
 
BEGIN
     CREATE INDEX [IDX_user_defined_deal_detail_fields_audit] ON [dbo].[user_defined_deal_detail_fields_audit] (source_deal_detail_id, udf_template_id, header_audit_id)
END
GO