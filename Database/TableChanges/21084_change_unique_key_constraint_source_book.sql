IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_source_book' AND object_id = OBJECT_ID(N'[dbo].[source_book]'))
BEGIN 
ALTER TABLE [dbo].[source_book] DROP CONSTRAINT [IX_source_book]
END

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_source_book' AND object_id = OBJECT_ID(N'[dbo].[source_book]'))
ALTER TABLE [dbo].[source_book] ADD CONSTRAINT [IX_source_book] UNIQUE NONCLUSTERED  ([source_system_id], [source_system_book_id], source_system_book_type_value_id) ON [PRIMARY]
GO