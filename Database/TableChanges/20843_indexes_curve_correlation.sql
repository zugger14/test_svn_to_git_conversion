
--Drop existing indexes that is not required
IF EXISTS (SELECT 1  FROM sys.indexes  
           WHERE name='IX_PT_curve_correlation_as_of_date_curve_source_value_id' 
             AND object_id = OBJECT_ID('[dbo].[curve_correlation]'))
BEGIN
    DROP INDEX IX_PT_curve_correlation_as_of_date_curve_source_value_id ON [dbo].[curve_correlation];
END
IF EXISTS (SELECT 1  FROM sys.indexes  
           WHERE name='IX_curve_correlation_1' 
             AND object_id = OBJECT_ID('[dbo].[curve_correlation]'))
BEGIN
    DROP INDEX IX_curve_correlation_1 ON [dbo].[curve_correlation];
END
IF EXISTS (SELECT 1  FROM sys.indexes  
           WHERE name='IX_curve_correlation_5' 
             AND object_id = OBJECT_ID('[dbo].[curve_correlation]'))
BEGIN
    DROP INDEX IX_curve_correlation_5 ON [dbo].[curve_correlation];
END
IF EXISTS (SELECT 1  FROM sys.indexes  
           WHERE name='IX_curve_correlation_6' 
             AND object_id = OBJECT_ID('[dbo].[curve_correlation]'))
BEGIN
    DROP INDEX IX_curve_correlation_6 ON [dbo].[curve_correlation];
END

--create new indexes 
IF NOT EXISTS (SELECT 1  FROM sys.indexes  
               WHERE name='IX_curve_correlation_1' 
                 AND object_id = OBJECT_ID('[dbo].[curve_correlation]'))
BEGIN
    CREATE NONCLUSTERED INDEX [ix_curve_correlation_1] ON [dbo].[curve_correlation] ([curve_id_from]);
END
IF NOT EXISTS (SELECT 1  FROM sys.indexes  
               WHERE name='IX_curve_correlation_5' 
                 AND object_id = OBJECT_ID('[dbo].[curve_correlation]'))
BEGIN
    CREATE NONCLUSTERED INDEX [ix_curve_correlation_5] ON [dbo].[curve_correlation] ([curve_id_to])
END
IF NOT EXISTS (SELECT 1  FROM sys.indexes  
               WHERE name='IX_curve_correlation_6' 
                 AND object_id = OBJECT_ID('[dbo].[curve_correlation]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_curve_correlation_6] ON [dbo].[curve_correlation] ([curve_source_value_id])
END
GO

--create computed columns and indexes on [dbo].[curve_correlation]
IF NOT EXISTS ( SELECT  1
				FROM    sys.computed_columns c
						JOIN sys.tables t ON t.object_id = c.object_id
				WHERE   t.name='curve_correlation'
				   and  c.name='as_of_date_char'
              )
BEGIN
    ALTER TABLE [dbo].[curve_correlation] ADD as_of_date_char AS CONVERT(VARCHAR, as_of_date, 101) PERSISTED
	IF EXISTS (SELECT 1  FROM sys.indexes  
           WHERE name='IX_curve_correlation_2' 
             AND object_id = OBJECT_ID('[dbo].[curve_correlation]'))
	BEGIN
		DROP INDEX  [IX_curve_correlation_2] ON [dbo].[curve_correlation] 
	END
	CREATE NONCLUSTERED INDEX [IX_curve_correlation_2] ON [dbo].[curve_correlation] (as_of_date_char)
END

IF NOT EXISTS ( SELECT  1
				FROM    sys.computed_columns c
						JOIN sys.tables t ON t.object_id = c.object_id
				WHERE   t.name='curve_correlation'
				   and  c.name='term1_char'
              )
BEGIN
    ALTER TABLE [dbo].[curve_correlation] ADD term1_char AS CONVERT(VARCHAR, term1, 101) PERSISTED
	IF EXISTS (SELECT 1  FROM sys.indexes  
           WHERE name='IX_curve_correlation_3' 
             AND object_id = OBJECT_ID('[dbo].[curve_correlation]'))
	BEGIN
		DROP INDEX  [IX_curve_correlation_3] ON [dbo].[curve_correlation] 
	END
	CREATE NONCLUSTERED INDEX [IX_curve_correlation_3] ON [dbo].[curve_correlation] (term1_char)
END

IF NOT EXISTS ( SELECT  1
				FROM    sys.computed_columns c
						JOIN sys.tables t ON t.object_id = c.object_id
				WHERE   t.name='curve_correlation'
				   and  c.name='term2_char'
              )
BEGIN
    ALTER TABLE [dbo].[curve_correlation] ADD term2_char AS CONVERT(VARCHAR, term2, 101) PERSISTED
	IF EXISTS (SELECT 1  FROM sys.indexes  
           WHERE name='IX_curve_correlation_4' 
             AND object_id = OBJECT_ID('[dbo].[curve_correlation]'))
	BEGIN
		DROP INDEX  [IX_curve_correlation_4] ON [dbo].[curve_correlation] 
	END
	CREATE NONCLUSTERED INDEX [IX_curve_correlation_4] ON [dbo].[curve_correlation] (term2_char)
END
GO
