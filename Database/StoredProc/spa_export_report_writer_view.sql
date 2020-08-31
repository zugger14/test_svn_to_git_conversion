
/****** Object:  StoredProcedure [dbo].[spa_export_report_writer_view]    Script Date: 07/28/2009 16:07:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_export_report_writer_view]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_export_report_writer_view]
GO

/****** Object:  StoredProcedure [dbo].[spa_export_report_writer_view]    Script Date: 07/28/2009 16:04:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
spa_export_report_writer_view 'MyCounterparty'
*/
CREATE procedure [dbo].[spa_export_report_writer_view] 
@report_name varchar(5000)
AS
SET NOCOUNT ON 
SET @report_name = '''' + REPLACE(@report_name, ',', ''',''') + ''''
--PRINT @report_name

--[report_writer_table]------------------------------------------------------------------
--set @report_name=REPLACE(report_name,',','','')
CREATE TABLE #tbl ( table_name1 varchar(200) COLLATE DATABASE_DEFAULT)
EXEC ('INSERT INTO #tbl (table_name1)  
SELECT table_name FROM [report_writer_table] WHERE table_name IN (' + @report_name + ')')

SELECT * INTO #report_writer_table
FROM [report_writer_table] a INNER JOIN #tbl b on a.table_name = b.table_name1
 
UPDATE #report_writer_table SET vw_sql = REPLACE(vw_sql, '''', '''''')

--Truncating the sql variable into smaller varibles since it was greater than the 8000 characters
--It was assumed that the sql variable would always be smaller than 75000 characters

DECLARE @count INT 
DECLARE @loop BIT
DECLARE @sql VARCHAR(MAX)
DECLARE @var1 VARCHAR(MAX)
DECLARE @var2 VARCHAR(MAX)
DECLARE @var3 VARCHAR(MAX)
DECLARE @var4 VARCHAR(MAX)
DECLARE @var5 VARCHAR(MAX)
DECLARE @var6 VARCHAR(MAX)
DECLARE @var7 VARCHAR(MAX)
DECLARE @var8 VARCHAR(MAX)
DECLARE @var9 VARCHAR(MAX)
DECLARE @var10 VARCHAR(MAX) 

SET @var1 = ''
SET @var2 = ''
SET @var3 = ''
SET @var4 = ''
SET @var5 = ''
SET @var6 = ''
SET @var7 = ''
SET @var8 = ''
SET @var9 = ''
SET @var10 = ''

SET @loop = 1
SET @count = 0

WHILE @loop = 1
BEGIN		
	SELECT @sql = SUBSTRING(vw_sql, 7500 * @count + 1, 7500) FROM  #report_writer_table
	SET @sql = REPLACE(REPLACE(REPLACE(ISNULL(@sql, ''), CHAR(9), ''' + CHAR(9) + '''), CHAR(10), ''' + CHAR(10) + '''),CHAR(13), ''' + CHAR(13) + ''')	
	
	IF LEN(@sql) >= 7500
		SET @loop = 1
	ELSE
		SET @loop = 0
		
	IF @count = 0 
		SET @var1 = @sql
	ELSE IF @count = 1		
		SET @var2 = @sql
	ELSE IF @count = 2		
		SET @var3 = @sql
	ELSE IF @count = 3		
		SET @var4 = @sql
	ELSE IF @count = 4		
		SET @var5 = @sql
	ELSE IF @count = 5		
		SET @var6 = @sql
	ELSE IF @count = 6		
		SET @var7 = @sql
	ELSE IF @count = 7		
		SET @var8 = @sql
	ELSE IF @count = 8		
		SET @var9 = @sql
	ELSE IF @count = 9		
		SET @var10 = @sql
	
	SET @count = @count + 1			
END
	


SELECT DISTINCT 'DELETE [report_where_column_required] WHERE table_name = ''' + table_name + '''' 
FROM [report_where_column_required] a 
INNER JOIN #tbl b on a.table_name = b.table_name1
UNION ALL
SELECT 'DELETE report_writer_table WHERE table_name = ''' + table_name + '''' 
FROM #report_writer_table
UNION ALL
SELECT 'DECLARE  @var1 VARCHAR(MAX), @var2 VARCHAR(MAX), @var3 VARCHAR(MAX), @var4 VARCHAR(MAX), @var5 VARCHAR(MAX), @var6 VARCHAR(MAX), @var7 VARCHAR(MAX), @var8 VARCHAR(MAX), @var9 VARCHAR(MAX), @var10 VARCHAR(MAX)  
		SET @var1 =''' + @var1 + '''
		SET @var2 =''' + @var2 + '''
		SET @var3 =''' + @var3 + '''
		SET @var4 =''' + @var4 + '''
		SET @var5 =''' + @var5 + '''
		SET @var6 =''' + @var6 + '''
		SET @var7 =''' + @var7 + '''
		SET @var8 =''' + @var8 + '''
		SET @var9 =''' + @var9 + '''
		SET @var10 =''' + @var10 + '''

		INSERT INTO report_writer_table ([table_name], [table_alias], [table_description], [vw_sql])
			VALUES (''' + table_name + ''', ''' +	ISNULL(table_alias, '') + ''', ''' + ISNULL(table_description, '') + ''',' 
				+ '@var1 + @var2 + @var3 + @var4 + @var5 + @var6 + @var7 + @var8 + @var9 + @var10' + '' + ')'  
FROM #report_writer_table
UNION ALL
--[report_where_column_required]---------------------------------
SELECT 'INSERT INTO [report_where_column_required] (
		[table_name], [column_name], [default_alias], [where_required], [create_user], [create_ts]
		, [update_user], [update_ts], [data_type], [clm_type], [control_type], [data_source], [default_value]) 
		VALUES (''' + table_name + ''', 
		''' + column_name + ''', 
		' + ISNULL('''' + default_alias + '''', 'NULL') + ',
		' + ISNULL('''' + CAST(where_required AS varchar(10)) + '''', 'NULL') + ', 
		''farrms_admin'', GETDATE(), ''farrms_admin'', GETDATE(), 
		' + ISNULL('''' + data_type + '''', 'NULL') + ',
		' + ISNULL('''' + CAST(clm_type AS varchar(10)) + '''', 'NULL') + ',
		' + ISNULL('''' + control_type + '''', 'NULL') + ',
		' + ISNULL('''' + REPLACE(REPLACE(REPLACE(ISNULL(REPLACE(data_source, '''', ''''''), ''), CHAR(9), ''' + CHAR(9) + '''), CHAR(10), ''' + CHAR(10) + '''),CHAR(13), ''' + CHAR(13) + ''') + '''', 'NULL') + ',
		' + ISNULL('''' + default_value + '''', 'NULL') + ')' 
FROM [report_where_column_required] a 
INNER JOIN  #tbl b ON a.table_name = b.table_name1


--' + ISNULL('''' + REPLACE(data_source, '''', '''''') + '''', 'NULL') + ',
