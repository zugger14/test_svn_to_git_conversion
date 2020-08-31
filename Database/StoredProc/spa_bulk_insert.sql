IF OBJECT_ID('spa_bulk_insert') IS NOT NULL
    DROP PROC spa_bulk_insert
GO
-- spa_bulk_insert 'D:\Privilege Report_2016_06_17_122130.csv', 'adiha_process.dbo.IMPORT_DATA_FARRMS_ADMIN_006D8B4C_8C15_4779_8018_AF9A71532E84'
CREATE PROC spa_bulk_insert
@csv_file VARCHAR(1024),
@table_name VARCHAR(1024),
@delimeter CHAR(1) = ',',
@row_terminator VARCHAR(10) = '\n',
@has_column_headers CHAR(1) = 'y',
@has_fields_enclosed_in_quotes CHAR(1) = 'n',
@rows_per_batch INT = 1024
AS
DECLARE @sql VARCHAR(MAX)
SET @sql = '
BULK
INSERT ' + @table_name + '
FROM ''' + @csv_file + '''
WITH
(
FIELDTERMINATOR = ''' + @delimeter + ''',
ROWTERMINATOR = ''' + @row_terminator + ''',
CODEPAGE = 65001,
ROWS_PER_BATCH  = ' + CAST(@rows_per_batch AS VARCHAR(25)) + ')'

--PRINT @sql
EXEC (@sql)
