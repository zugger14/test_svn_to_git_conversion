IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_price_data_import_renewables_market]') AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_price_data_import_renewables_market]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/** 
	SP to manipulate price curve process table data for futher processing

	Parameters:
	@process_table : Input Process table
	@process_id	   : Process Id	
	@process_name  : Process name
*/

CREATE PROCEDURE [dbo].[spa_price_data_import_renewables_market] 
	@process_table   VARCHAR(500) = NULL,
	@process_id VARCHAR(75) = NULL,
	@process_name VARCHAR(200) = NULL

AS
SET NOCOUNT ON

DECLARE @user_login_id VARCHAR(100)
SET @user_login_id = dbo.FNADBUser()  

IF CHARINDEX('adiha_process.dbo.temp_import_data_table_pc_', @process_table) > 0
BEGIN
	SET @process_id = REPLACE(@process_table,'adiha_process.dbo.temp_import_data_table_pc_','')
END
ELSE
BEGIN
	SET @process_id =  REPLACE(@process_table,'adiha_process.dbo.temp_file_table_' + @user_login_id, '')
END

SET @process_name = REPLACE(@process_table,'adiha_process.dbo.','')

DECLARE @process_table_final VARCHAR(800) 

IF CHARINDEX('adiha_process.dbo.temp_import_data_table_pc_', @process_table) > 0
BEGIN
	SET @process_table_final =  CONCAT('adiha_process.dbo.','temp_import_data_table_pc_', @process_id, '_final')
END
ELSE
BEGIN
	SET @process_table_final =  CONCAT('adiha_process.dbo.','temp_file_table_' + @user_login_id, @process_id, '_final')
END

--EXEC('drop table ' +  @process_table_final)
EXEC('IF OBJECT_ID( ''' + @process_table_final + ''') IS NOT NULL DROP TABLE ' + @process_table_final )

CREATE TABLE  #temp_update_table (
	Column1 VARCHAR(3000) COLLATE DATABASE_DEFAULT
	,Column2 VARCHAR(3000) COLLATE DATABASE_DEFAULT
	,Column3 VARCHAR(3000) COLLATE DATABASE_DEFAULT
	,Column4 VARCHAR(3000) COLLATE DATABASE_DEFAULT
	,Column5 VARCHAR(3000) COLLATE DATABASE_DEFAULT
	,Column6 VARCHAR(3000) COLLATE DATABASE_DEFAULT
	,Column7 VARCHAR(3000) COLLATE DATABASE_DEFAULT
	,Column8 VARCHAR(3000) COLLATE DATABASE_DEFAULT
	,Column9 VARCHAR(3000) COLLATE DATABASE_DEFAULT
	,Column10 VARCHAR(3000) COLLATE DATABASE_DEFAULT
	,Column11 VARCHAR(3000) COLLATE DATABASE_DEFAULT
	,Column12 VARCHAR(3000) COLLATE DATABASE_DEFAULT
	,Column13 VARCHAR(3000) COLLATE DATABASE_DEFAULT
	,Column14 VARCHAR(3000) COLLATE DATABASE_DEFAULT
	,Column15 VARCHAR(3000) COLLATE DATABASE_DEFAULT
	,import_file_name VARCHAR(600) COLLATE DATABASE_DEFAULT
)

EXEC('CREATE TABLE  ' + @process_table_final + ' (
	[Curve ID] VARCHAR(500) COLLATE DATABASE_DEFAULT,
	[As of Date] DATETIME,
	[Source Curve Name] varchar(500) COLLATE DATABASE_DEFAULT,
	[Maturity Date] DATETIME,
	[Hour] INT,
	[Minute] INT,
	[Bid Value] FLOAT,
	[Ask Value] FLOAT,
	[Curve Value] FLOAT,
	[IS DST] INT
	)'
)

EXEC ('INSERT INTO #temp_update_table SELECT * FROM  '+ @process_table + '')
EXEC ('DELETE FROM  #temp_update_table WHERE Column1 = '''' AND Column11 = ''''')

CREATE TABLE #temp_table (
	ID INT,
	table_id INT,
	[name] VARCHAR(1000) COLLATE DATABASE_DEFAULT
)

CREATE TABLE #List_sql (
	script_list VARCHAR(1000) COLLATE DATABASE_DEFAULT
)

CREATE TABLE #curve_values (
	curve_name VARCHAR(3000) COLLATE DATABASE_DEFAULT,
	Term VARCHAR(3000) COLLATE DATABASE_DEFAULT,
	Bid VARCHAR(3000) COLLATE DATABASE_DEFAULT,
	Ask VARCHAR(3000) COLLATE DATABASE_DEFAULT,
	Mid  VARCHAR(3000) COLLATE DATABASE_DEFAULT
)

DECLARE @as_of_date VARCHAR (200)
	
SELECT @as_of_date = sc.name
FROM adiha_process.dbo.sysobjects so
INNER JOIN adiha_process.dbo.syscolumns sc
	ON so.id = sc.id
WHERE so.name = @process_name
	AND sc.name NOT LIKE 'Column%'
	AND sc.name NOT LIKE '%import_file_name%'
	
--Generate number of sets from import file.
--Declare @column_count INT = (SELECT count1)
--FROM    sys.columns
--WHERE   OBJECT_NAME(object_id) = @process_table_update)
DECLARE @count int = 3 -- @column_count/5
----- Get Column Names

DECLARE @i INT = 0
WHILE @i < @count
BEGIN
	DECLARE @sql VARCHAR(MAX)
	SET @i = @i + 1
	INSERT INTO #temp_table 
	SELECT  ROW_NUMBER()OVER (ORDER BY RIGHT('0000000000' + SUBSTRING(sc.name, ISNULL(NULLIF(PATINDEX('%[0-9]%',sc.name), 0), LEN(sc.name)+1), LEN(sc.name)), 10) ASC) AS ID, @i AS i, sc.name
	FROM   tempdb.sys.columns sc
	WHERE [object_id] = OBJECT_ID(N'tempdb.dbo.#temp_update_table')
	AND sc.column_id  BETWEEN (5 *(@i- 1)) + 1 AND 5 * @i
	ORDER BY i,ID ASC
END

---Get Select Query
	INSERT INTO #List_sql
	SELECT CONCAT('Select ',STUFF((SELECT ', ' + CAST(Name AS VARCHAR(10)) [text()]
         FROM #temp_table 
         WHERE table_id = t.table_id
         FOR XML PATH(''), TYPE)
        .value('.','NVARCHAR(MAX)'),1,2,' ') 
		,' From #temp_update_table')
	FROM #temp_table t
	GROUP BY table_id

--Insert curve data in temp table.
IF CURSOR_STATUS('local','insert_price_curve_data') > = -1
BEGIN
	DEALLOCATE insert_price_curve_data
END

DECLARE insert_price_curve_data CURSOR LOCAL FOR
SELECT script_list
FROM   #List_sql
DECLARE @price_curve_sql VARCHAR(1000)
	
OPEN insert_price_curve_data 
FETCH NEXT FROM insert_price_curve_data 
INTO @price_curve_sql
WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO #curve_values
	(curve_name,term,bid,ask,mid)
	EXEC(@price_curve_sql)		
			
	FETCH NEXT FROM insert_price_curve_data INTO @price_curve_sql
END
CLOSE insert_price_curve_data
DEALLOCATE insert_price_curve_data
		
-- Insert data in final process table. 
EXEC('	
	INSERT INTO ' + @process_table_final + '	
	SELECT curve_name,
	CONCAT(YEAR('''+ @as_of_date + '''),''-'',MONTH('''+ @as_of_date + '''),''-'',DAY('''+ @as_of_date + ''')),
	''Master'' as [Source Curve Name],
	concat(term, ''-01-'', ''01'') maturity_date,
	NULL AS Hour,
	NULL AS Minute,
	CAST(REPLACE(REPLACE(bid,''$'',''''),''_-'','''') AS FLOAT),
	CAST (REPLACE(REPLACE(ask,''$'',''''),''_-'','''') AS FLOAT),
	CAST(REPLACE(REPLACE(mid,''$'',''''),''_-'','''') AS FLOAT),
	0 AS [IS DST]
	FROM  #curve_values
	WHERE NULLIF(ISNULL(curve_name,''''),'''') != '''' AND curve_name!= ''Product'' AND NULLIF(ISNULL(term,''''),'''') != ''''
	ORDER BY curve_name, term'
)

