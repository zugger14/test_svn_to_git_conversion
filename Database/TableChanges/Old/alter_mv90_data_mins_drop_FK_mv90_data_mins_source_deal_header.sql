IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_mv90_data_mins_source_deal_header]') AND parent_object_id = OBJECT_ID(N'[dbo].[mv90_data_mins]'))
ALTER TABLE [dbo].[mv90_data_mins] DROP CONSTRAINT [FK_mv90_data_mins_source_deal_header]