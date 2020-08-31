
/****** Object:  StoredProcedure [dbo].[spa_export_report_writer_report]    Script Date: 07/28/2009 16:08:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_export_report_writer_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_export_report_writer_report]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
exec spa_export_report_writer_report 'ttttt,Detailed Msmt Report'
*/
CREATE PROCEDURE [dbo].[spa_export_report_writer_report] 
	@report_name varchar(5000)
AS
SET NOCOUNT ON 

SET @report_name = '''' + REPLACE(@report_name, ',', ''', ''') + ''''

CREATE TABLE #tbl ( r_id int,report_name1 varchar(200) COLLATE DATABASE_DEFAULT)
EXEC ('INSERT INTO #tbl (r_id, report_name1)  
		SELECT report_id,report_name FROM [Report_record] WHERE report_name in (' + @report_name + ')')

SELECT * INTO #report_writer_column FROM [report_writer_column] a 
INNER JOIN #tbl b ON a.report_id = b.r_id

UPDATE #report_writer_column SET filter_column = REPLACE(filter_column, '''', '''''')

SELECT * INTO #Report_record 
FROM [Report_record] a 
INNER JOIN  #tbl b on a.report_id = b.r_id

UPDATE #Report_record SET report_WHERE = REPLACE(report_WHERE, '''', '''''')
	, report_groupby = REPLACE(report_groupby, '''', '''''')
	, report_having = REPLACE(report_having, '''', '''''')
	, report_orderby = REPLACE(report_orderby, '''', '''''')
	, report_sql_statement = REPLACE(report_sql_statement, '''', '''''')
	
--Truncating the sql variable into smaller varibles since it was greater than the 8000 characters
--Assumed that the sql variable would always be smaller than 75000 characters

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
	SELECT @sql = SUBSTRING(report_sql_statement, 7500 * @count + 1, 7500) FROM  #Report_record
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

SELECT DISTINCT 'DELETE report_writer_column FROM report_writer_column a INNER JOIN Report_record b on a.report_id = b.report_id WHERE report_name = ''' + report_name1 + '''' 
FROM #report_writer_column
UNION ALL
SELECT 'DELETE Report_record WHERE report_name = ''' + report_name + '''' FROM #Report_record
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

		INSERT INTO [Report_record] ([report_name], [report_owner], [report_tablename]
		, [report_groupby], [report_WHERE], [report_having], [report_orderby], [report_sql_statement]
		, [report_public], [report_internal_description], [report_sql_check], [create_ts], [create_user], [update_ts]
		, [update_user], [report_category_id]) VALUES (''' + ISNULL(report_name, '') + ''', ''' + ISNULL(report_owner, '') + ''', '''
		+ ISNULL(report_tablename, '') + ''', ''' + ISNULL(report_groupby, '')
		+ ''', ''' + ISNULL(report_where, '') + ''', ''' + ISNULL(report_having, '') + ''', ''' + ISNULL(report_orderby, '')
		+ ''', '
		+ '@var1 + @var2 + @var3 + @var4 + @var5 + @var6 + @var7 + @var8 + @var9 + @var10' 
		+ ', ''' + ISNULL(report_public, '')
		+ ''', ''' + ISNULL(report_internal_description, '') + ''', ''' + ISNULL(report_sql_check, '')
		+ ''', GETDATE(), ''farmms_admin'', GETDATE(), ''farmms_admin'', ' + ISNULL(CAST(report_category_id AS VARCHAR(50)), 'NULL') + ')'
FROM #Report_record
UNION ALL
SELECT 'INSERT INTO report_writer_column ([report_id]
		, [column_id], [column_selected], [column_name], [columns], [column_alias], [filter_column], [max]
		, [min], [count], [sum], [average], [create_user], [create_ts], [update_user], [update_ts], [user_define]
		, [data_type], [control_type], [data_source], [default_value]) SELECT 
		report_id , ' + CAST(column_id AS varchar)+ ', ''' +
		ISNULL(column_selected, '') + ''', ''' +
		ISNULL(column_name, '') + ''', ''' +
		ISNULL(columns, '') + ''', ''' +
		ISNULL(column_alias, '') + ''', ''' +
		ISNULL(filter_column, '') + ''', ''' +
		ISNULL([max], '') + ''', ''' +
		ISNULL([min], '') + ''', ''' +
		ISNULL([count], '') + ''', ''' +
		ISNULL([sum], '') + ''', ''' +
		ISNULL([average], '') + ''', ''farrms_admin'', GETDATE()
		, ''farrms_admin'', GETDATE(), ''' + 
		ISNULL(user_define, '') + ''', ''' + 
		ISNULL(data_type, '') + ''', 
		' + ISNULL('''' + control_type + '''', 'NULL') + ',
		' + ISNULL('''' + REPLACE(REPLACE(REPLACE(ISNULL(REPLACE(data_source, '''', ''''''), ''), CHAR(9), ''' + CHAR(9) + '''), CHAR(10), ''' + CHAR(10) + '''),CHAR(13), ''' + CHAR(13) + ''') + '''', 'NULL') + ',
		' + ISNULL('''' + default_value + '''', 'NULL') + ' FROM [Report_record] WHERE [report_name] = ''' + b.report_name1 + ''''
FROM #report_writer_column a INNER JOIN #tbl b on a.report_id = b.r_id
