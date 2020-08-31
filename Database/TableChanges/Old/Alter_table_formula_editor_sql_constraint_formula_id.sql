IF EXISTS (
       SELECT *
       FROM   sys.foreign_keys
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[FK_formula_editor_sql_formula_editor]')
              AND parent_object_id = OBJECT_ID(N'[dbo].[formula_editor_sql]')
   )
    ALTER TABLE [dbo].[formula_editor_sql] DROP CONSTRAINT [FK_formula_editor_sql_formula_editor] 
GO

IF NOT EXISTS (
       SELECT *
       FROM   sys.foreign_keys
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[FK_formula_editor_sql_formula_editor]')
              AND parent_object_id = OBJECT_ID(N'[dbo].[formula_editor_sql]')
   )
    ALTER TABLE [dbo].[formula_editor_sql] WITH CHECK ADD CONSTRAINT 
    [FK_formula_editor_sql_formula_editor] FOREIGN KEY([formula_id])
    REFERENCES [dbo].[formula_editor] ([formula_id])
GO

IF EXISTS (
       SELECT *
       FROM   sys.foreign_keys
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[FK_formula_editor_sql_formula_editor]')
              AND parent_object_id = OBJECT_ID(N'[dbo].[formula_editor_sql]')
   )
    ALTER TABLE [dbo].[formula_editor_sql] CHECK CONSTRAINT [FK_formula_editor_sql_formula_editor]
GO