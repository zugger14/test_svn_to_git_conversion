/****** Object:  StoredProcedure [dbo].[spa_contract_group]    Modified Date: 24/08/2016 ******/
IF OBJECT_ID('[dbo].[spa_GetUniqueCopyName]') IS NOT  null
	DROP PROC [dbo].[spa_GetUniqueCopyName]
GO
CREATE PROC [dbo].[spa_GetUniqueCopyName] (
		@column_value VARCHAR(100),
		@column_name VARCHAR(100),
		@table_name VARCHAR(100), 
		@where_clause VARCHAR(1000)=NULL,
		@unique_name VARCHAR(500) OUTPUT)
AS
SET NOCOUNT ON

if OBJECT_ID('tempdb..#tmp_data') is not null
	drop table #tmp_data

CREATE TABLE #tmp_data (last_copy_no INT, total_count INT)
DECLARE @SQLString VARCHAR(MAX)
SET @SQLString='INSERT INTO #tmp_data (last_copy_no ,total_count) SELECT MAX(CAST(SUBSTRING(' + @column_name + ',5,CASE WHEN CHARINDEX('' of'',' + @column_name + ', 5)> 5 
			THEN CHARINDEX('' of'',' + @column_name + ',5)- 5 ELSE 0 END) AS INT)), COUNT(1) FROM ' + @table_name + 
			' WHERE ' + @column_name + ' LIKE ''copy %' + @column_value + '''' + 
			CASE WHEN @where_clause IS NULL THEN '' ELSE  ' AND ' + @where_clause END


EXEC spa_print @SQLString
EXEC(@SQLString)

SELECT @unique_name='Copy ' + CASE WHEN total_count > 0 AND ISNULL(last_copy_no, 0) = 0 THEN CAST(total_count+1 AS VARCHAR) + ' '
					WHEN ISNULL(total_count, 0) = 0 AND ISNULL(last_copy_no, 0) = 0 THEN '' 
					ELSE CAST(ISNULL(last_copy_no, 0) + 1 AS VARCHAR) + ' ' END + 'of ' + @column_value FROM #tmp_data

EXEC spa_print @unique_name




