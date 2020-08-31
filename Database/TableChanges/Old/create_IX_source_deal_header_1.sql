IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.source_deal_header') AND name = N'IX_source_deal_header_1')
BEGIN
	drop index IX_source_deal_header_1 on dbo.source_deal_header
	create index idx_source_deal_header_deal_date on dbo.source_deal_header (deal_date)
	create index idx_source_deal_header_structured_deal_id on dbo.source_deal_header (structured_deal_id)
	create index idx_source_deal_header_ext_deal_id on dbo.source_deal_header (ext_deal_id)
END