IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND tc.Table_Name = 'ixp_import_data_mapping'
                    AND ccu.COLUMN_NAME = 'dest_table_id'          
)
ALTER TABLE [dbo].[ixp_import_data_mapping] WITH NOCHECK ADD CONSTRAINT [FK_ixp_import_data_mapping_ixp_tables] FOREIGN KEY([dest_table_id])
REFERENCES [dbo].[ixp_tables] ([ixp_tables_id])
GO

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND tc.Table_Name = 'ixp_import_data_mapping'
                    AND ccu.COLUMN_NAME = 'dest_column'
)
ALTER TABLE [dbo].[ixp_import_data_mapping] WITH NOCHECK ADD CONSTRAINT [FK_ixp_import_data_mapping_ixp_columns] FOREIGN KEY([dest_column])
REFERENCES [dbo].[ixp_columns] ([ixp_columns_id])
GO

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND tc.Table_Name = 'ixp_export_tables'
                    AND ccu.COLUMN_NAME = 'table_id'
)
ALTER TABLE [dbo].[ixp_export_tables] WITH NOCHECK ADD CONSTRAINT [FK_ixp_export_tables_ixp_tables] FOREIGN KEY([table_id])
REFERENCES [dbo].[ixp_tables] ([ixp_tables_id])
GO

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND tc.Table_Name = 'ixp_data_mapping'
                    AND ccu.COLUMN_NAME = 'table_id'
)
ALTER TABLE [dbo].[ixp_data_mapping] WITH NOCHECK ADD CONSTRAINT [FK_ixp_data_mapping_ixp_tables] FOREIGN KEY([table_id])
REFERENCES [dbo].[ixp_tables] ([ixp_tables_id])
GO

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND tc.Table_Name = 'ixp_data_mapping'
                    AND ccu.COLUMN_NAME = 'main_table'
)
ALTER TABLE [dbo].[ixp_data_mapping] WITH NOCHECK ADD CONSTRAINT [FK_ixp_data_mapping_ixp_export_data_source] FOREIGN KEY([main_table])
REFERENCES [dbo].[ixp_export_data_source] ([ixp_export_data_source_id])
GO


IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND tc.Table_Name = 'ixp_import_where_clause'
                    AND ccu.COLUMN_NAME = 'table_id'          
)
ALTER TABLE [dbo].[ixp_import_where_clause] WITH NOCHECK ADD CONSTRAINT [FK_ixp_import_where_clause_ixp_tables] FOREIGN KEY([table_id])
REFERENCES [dbo].[ixp_tables] ([ixp_tables_id])
GO


IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND tc.Table_Name = 'ixp_import_query_builder_import_tables'
                    AND ccu.COLUMN_NAME = 'table_id'          
)
ALTER TABLE [dbo].[ixp_import_query_builder_import_tables] WITH NOCHECK ADD CONSTRAINT [FK_ixp_import_query_builder_import_tables_ixp_tables] FOREIGN KEY([table_id])
REFERENCES [dbo].[ixp_tables] ([ixp_tables_id])
GO

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND tc.Table_Name = 'ixp_import_relation'
                    AND ccu.COLUMN_NAME = 'ixp_rules_id'          
)

ALTER TABLE [dbo].[ixp_import_relation] WITH NOCHECK ADD CONSTRAINT [FK_ixp_import_relation_ixp_rules] FOREIGN KEY([ixp_rules_id])
REFERENCES [dbo].[ixp_rules] ([ixp_rules_id])
GO

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
                    AND   tc.Table_Name = 'ixp_exportable_table' 
                    AND ccu.COLUMN_NAME = 'ixp_exportable_table_id'
)
ALTER TABLE [dbo].[ixp_exportable_table] WITH NOCHECK ADD CONSTRAINT [PK_ixp_exportable_table] PRIMARY KEY([ixp_exportable_table_id])
GO

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND tc.Table_Name = 'ixp_export_data_source'
                    AND ccu.COLUMN_NAME = 'export_table'          
)
ALTER TABLE [dbo].[ixp_export_data_source] WITH NOCHECK ADD CONSTRAINT [FK_ixp_export_data_source_ixp_exportable_table] FOREIGN KEY([export_table])
REFERENCES [dbo].[ixp_exportable_table] ([ixp_exportable_table_id])
GO