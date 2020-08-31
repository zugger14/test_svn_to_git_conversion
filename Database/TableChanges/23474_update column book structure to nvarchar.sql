
EXEC sp_fulltext_column      
@tabname =  'portfolio_hierarchy' , 
@colname =  'entity_name' , 
@action =  'drop' 
GO

--IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'uc_portfolio_hierarchy' AND object_id = OBJECT_ID(N'[dbo].[portfolio_hierarchy]'))
--BEGIN 
--DROP Index portfolio_hierarchy.uc_portfolio_hierarchy
--END
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'uc_portfolio_hierarchy' AND object_id = OBJECT_ID(N'[dbo].[portfolio_hierarchy]'))
BEGIN 
ALTER TABLE [dbo].[portfolio_hierarchy] DROP CONSTRAINT [uc_portfolio_hierarchy]
END


IF COL_LENGTH('portfolio_hierarchy', 'entity_name') IS NOT NULL
BEGIN
    ALTER TABLE portfolio_hierarchy ALTER COLUMN entity_name NVARCHAR(100)
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'uc_portfolio_hierarchy' AND object_id = OBJECT_ID(N'[dbo].[portfolio_hierarchy]'))
ALTER TABLE [dbo].[portfolio_hierarchy] ADD CONSTRAINT [uc_portfolio_hierarchy] UNIQUE NONCLUSTERED  ([entity_name], [hierarchy_level], parent_entity_id) ON [PRIMARY]
GO

EXEC sp_fulltext_column      
@tabname =  'portfolio_hierarchy' , 
@colname =  'entity_name' , 
@action =  'add' 
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_source_book' AND object_id = OBJECT_ID(N'[dbo].[source_book]'))
BEGIN 
ALTER TABLE [dbo].[source_book] DROP CONSTRAINT [IX_source_book]
END

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_source_book_1' AND object_id = OBJECT_ID(N'[dbo].[source_book]'))
BEGIN 
DROP Index source_book.IX_source_book_1
END

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'indx_source_book_name_tm' AND object_id = OBJECT_ID(N'[dbo].[source_book]'))
BEGIN 
DROP Index source_book.indx_source_book_name_tm
END


IF COL_LENGTH('source_book', 'source_system_book_id') IS NOT NULL
BEGIN
    ALTER TABLE source_book ALTER COLUMN source_system_book_id NVARCHAR(50)
END
GO
IF COL_LENGTH('source_book', 'source_book_name') IS NOT NULL
BEGIN
    ALTER TABLE source_book ALTER COLUMN source_book_name NVARCHAR(50)
END
GO
IF COL_LENGTH('source_book', 'source_parent_book_id') IS NOT NULL
BEGIN
    ALTER TABLE source_book ALTER COLUMN source_parent_book_id NVARCHAR(50)
END
GO

IF COL_LENGTH('source_book', 'source_book_desc') IS NOT NULL
BEGIN
    ALTER TABLE source_book ALTER COLUMN source_book_desc NVARCHAR(100)
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_source_book' AND object_id = OBJECT_ID(N'[dbo].[source_book]'))
ALTER TABLE [dbo].[source_book] ADD CONSTRAINT [IX_source_book] UNIQUE NONCLUSTERED  ([source_system_id], [source_system_book_id], source_system_book_type_value_id) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_source_book_1' AND object_id = OBJECT_ID(N'[dbo].[source_book]'))
	CREATE NONCLUSTERED INDEX IX_source_book_1
	ON source_book(source_book_id);

GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'indx_source_book_name_tm' AND object_id = OBJECT_ID(N'[dbo].[source_book]'))
	CREATE NONCLUSTERED INDEX indx_source_book_name_tm
	ON source_book(source_book_name);
	GO



IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UC_logical_name' AND object_id = OBJECT_ID(N'[dbo].[source_system_book_map]'))
BEGIN 
ALTER TABLE [dbo].[source_system_book_map] DROP CONSTRAINT [UC_logical_name]
END

IF COL_LENGTH('source_system_book_map', 'logical_name') IS NOT NULL
BEGIN
    ALTER TABLE source_system_book_map ALTER COLUMN logical_name NVARCHAR(100)
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UC_logical_name' AND object_id = OBJECT_ID(N'[dbo].[source_system_book_map]'))
ALTER TABLE [dbo].[source_system_book_map] ADD CONSTRAINT [UC_logical_name] UNIQUE NONCLUSTERED  ([logical_name]) ON [PRIMARY]
GO
