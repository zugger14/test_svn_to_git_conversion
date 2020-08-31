IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_deal_header_source_deal_header1]') AND parent_object_id = OBJECT_ID(N'[dbo].[source_deal_header]'))
ALTER TABLE [dbo].[source_deal_header] DROP CONSTRAINT [FK_source_deal_header_source_deal_header1]
GO
