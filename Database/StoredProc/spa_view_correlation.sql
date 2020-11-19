IF OBJECT_ID(N'[dbo].[spa_view_correlation]', N'P') IS NOT NULL
   DROP PROCEDURE [dbo].spa_view_correlation

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_view_correlation]
	@flag CHAR(1) = Null,
	@xml XML= NULL,
	@curve_id_from VARCHAR(max) = NULL,
	@curve_id_to VARCHAR(max) = NULL,
	@curve_source_value_id VARCHAR(1000) = NULL,
	@as_of_date_from VARCHAR(20) = NULL,
	@as_of_date_to VARCHAR(20) = NULL,
	@term_from VARCHAR(20) = NULL,
	@term_to VARCHAR(20) = NULL,
	@round_value VARCHAR(10) = 4,
	@process_id VARCHAR(200) = NULL,
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,		--'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
AS

/*-----------------------DEBUG CODE-------------------------

DECLARE
	@flag CHAR(1) = Null,
	@xml XML= NULL,
	@curve_id_from VARCHAR(max) = NULL,
	@curve_id_to VARCHAR(max) = NULL,
	@curve_source_value_id VARCHAR(1000) = NULL,
	@as_of_date_from VARCHAR(20) = NULL,
	@as_of_date_to VARCHAR(20) = NULL,
	@term_from VARCHAR(20) = NULL,
	@term_to VARCHAR(20) = NULL,
	@round_value VARCHAR(10) = 4,
	@process_id VARCHAR(200) = NULL,
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,
	@page_size INT = NULL,
	@page_no INT = NULL

SELECT @flag='i',@xml='<Root><GridGroup><Grid><GridRow as_of_date="2017-12-01" curve_id_from="IFERC Socal" curve_id_to="IFERC Socal" term1="2018-01-01" term2="2018-01-01" curve_source_value_id="Historical" value="1"></GridRow><GridRow as_of_date="2017-12-01" curve_id_from="IFERC Socal" curve_id_to="IFERC Socal" term1="2018-02-01" term2="2018-02-01" curve_source_value_id="Historical" value="1"></GridRow><GridRow as_of_date="2017-12-01" curve_id_from="IFERC Socal" curve_id_to="IFERC Socal" term1="2018-03-01" term2="2018-03-01" curve_source_value_id="Historical" value="1"></GridRow><GridRow as_of_date="2017-12-01" curve_id_from="IFERC Socal" curve_id_to="Palo Verde Forward RTC" term1="2018-01-01" term2="2018-01-01" curve_source_value_id="Historical" value=""></GridRow></Grid></GridGroup></Root>'

*/

SET NOCOUNT ON

DECLARE @header_detail CHAR(1)
DECLARE @sql VARCHAR(MAX)
DECLARE @column_title_ask VARCHAR(MAX) = ''
DECLARE @where_sql VARCHAR(MAX)
DECLARE @order_sql VARCHAR(MAX)
DECLARE @curve_source_column_list VARCHAR(MAX)=''
DECLARE @pivot_query_sql1 VARCHAR(MAX) = '' 
DECLARE @pivot_query_sql2 VARCHAR(MAX) = '' 
DECLARE @table_name VARCHAR(500)
DECLARE @ParmDefinition nVARCHAR(500) = ''
DECLARE @header_query_1 nVarchar(MAX)
DECLARE @header_list nVARCHAR(MAX) = ''
DECLARE @select_sql VARCHAR(MAX)
DECLARE @date_diff INT = NULL;
DECLARE @sql_term_date VARCHAR(MAX) = NULL;

/*******************************************1st Paging Batch START**********************************************/ 
DECLARE @str_batch_table VARCHAR (8000) 
DECLARE @user_login_id VARCHAR (50) 
DECLARE @sql_paging VARCHAR (8000) 
DECLARE @is_batch BIT 
SET @str_batch_table = '' 
SET @user_login_id = dbo.FNADBUser()  
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 
 
IF @is_batch = 1 
BEGIN 
	SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id) 
END
 
IF @enable_paging = 1 --paging processing 
BEGIN 
	IF @batch_process_id IS NULL 
	BEGIN 
		SET @batch_process_id = dbo.FNAGetNewID() 
		SET @str_batch_table = dbo.FNAPagingProcess ('p', @batch_process_id, @page_size, @page_no) 
	END
	--retrieve data from paging table instead of main table 
	IF @page_no IS NOT NULL  
	BEGIN 
		SET @sql_paging = dbo.FNAPagingProcess ('s', @batch_process_id, @page_size, @page_no)  
		EXEC (@sql_paging)  
		RETURN  
	END 
END 
/*******************************************1st Paging Batch END**********************************************/

IF @process_id IS NULL 
BEGIN 
	 SET @header_detail = 'h' 
	 SET @process_id = dbo.FNAGetNewID()
END

DECLARE @process_table VARCHAR(500) = dbo.FNAProcessTableName('view_correlation',dbo.FNADBUser(),@process_id)

SELECT @table_name =  REPLACE(@process_table, 'adiha_process.dbo.', '')

IF @flag = 's'
BEGIN
	DECLARE @is_term_null INT = 0
	SET @as_of_date_from = NULLIF(@as_of_date_from,'')
 	SET @as_of_date_to = NULLIF(@as_of_date_to,'')
 	SET @term_from = NULLIF(@term_from,'')
 	SET @term_to = NULLIF(@term_to,'')
	
	IF @header_detail = 'h'
	BEGIN
		SET @where_sql = ' WHERE 1 = 1'
		
		IF @as_of_date_from IS NULL
		BEGIN
			SET @as_of_date_from = (
									SELECT CAST(dbo.FNAGetSQLStandardDate(MAX(cc.as_of_date)) AS VARCHAR(20)) 
									FROM curve_correlation cc
								   )
		END
		
		IF @term_to IS NULL AND @term_from IS NULL
		BEGIN
			SET @is_term_null = 1
			SELECT @term_to = CAST(MAX(term2) AS DATE) 
			FROM curve_correlation
			WHERE CAST(as_of_date AS DATE) =  @as_of_date_from
			AND curve_id_from = @curve_id_from AND curve_id_to = @curve_id_to
		END
		ELSE IF @term_to IS NULL AND @term_from IS NOT NULL
			SET @term_to = @term_from
		BEGIN
			SET @term_to = DATEADD(MONTH, DATEDIFF(m, 0, @term_to), 0)
			SET @term_to = CONVERT(DATE, @term_to)
		END

		IF @term_from IS NULL
		BEGIN
			SELECT @term_from = CAST(MIN(term1) AS DATE) 
			FROM curve_correlation
			WHERE CAST(as_of_date AS DATE) =  @as_of_date_from
			AND curve_id_from = @curve_id_from AND curve_id_to = @curve_id_to
		END
		ELSE
		BEGIN
			SET @term_from = DATEADD(MONTH, DATEDIFF(m, 0, @term_from), 0)
			SET @term_from = CONVERT(DATE, @term_from)
		END

		SET @date_diff = (DATEDIFF(MONTH, @term_from, @term_to) + 1)

		IF OBJECT_ID('tempdb..#risk_bucket_from') IS NOT NULL
			DROP TABLE #risk_bucket_from
		IF OBJECT_ID('tempdb..#risk_bucket_to') IS NOT NULL
			DROP TABLE #risk_bucket_to
		IF OBJECT_ID('tempdb..#curve_source_value_list') IS NOT NULL
			DROP TABLE #curve_source_value_list
		IF OBJECT_ID('tempdb..#curve_correlation_column_header') IS NOT NULL
			DROP TABLE #curve_correlation_column_header
		IF OBJECT_ID('tempdb..#term_date_combo') IS NOT NULL
			DROP TABLE #term_date_combo
		IF OBJECT_ID('tempdb..#as_of_date') IS NOT NULL
			DROP TABLE #as_of_date
		IF OBJECT_ID('tempdb..#temp_header_list_old') IS NOT NULL
			DROP TABLE #temp_header_list_old
		IF OBJECT_ID('tempdb..#temp_header_list') IS NOT NULL
			DROP TABLE #temp_header_list
		IF OBJECT_ID('tempdb..#term_date_combo_header') IS NOT NULL
			DROP TABLE #term_date_combo_header
		IF OBJECT_ID('tempdb..#curve_detail_data') IS NOT NULL
			DROP TABLE #curve_detail_data
			
		
		CREATE TABLE #risk_bucket_from(
 			rowID int not null identity(1,1),
 			curve_id_from INT,
 			UNIQUE(curve_id_from) 
 		)

		CREATE TABLE #risk_bucket_to(
 			rowID int not null identity(1,1),
 			curve_id_to INT,
 			UNIQUE(curve_id_to) 
 		)

		CREATE TABLE #curve_source_value_list(
 			rowID int not null identity(1,1),
 			curve_source_value_id INT
 			UNIQUE(curve_source_value_id)
 		)

		CREATE TABLE #curve_correlation_column_header(
 			row_id INT IDENTITY(1,1),
			as_of_date VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			curve_id_from INT,
			curve_id_to INT,
 			term1 VARCHAR(100) COLLATE DATABASE_DEFAULT ,
 			term2 VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			curve_value FLOAT,
			curve_source_value_id INT,
 			column_header VARCHAR(200) COLLATE DATABASE_DEFAULT 
 		)
		
		IF @curve_id_from IS NOT NULL
 		BEGIN	
 			INSERT INTO #risk_bucket_from(curve_id_from)
 			SELECT CAST(Item AS INT) curve_id_from FROM  dbo.SplitCommaSeperatedValues(@curve_id_from)
 		END;

		IF @curve_id_to IS NOT NULL
 		BEGIN	
 			INSERT INTO #risk_bucket_to(curve_id_to)
 			SELECT CAST(Item AS INT) curve_id_to FROM  dbo.SplitCommaSeperatedValues(@curve_id_to)
 		END;

		IF @curve_source_value_id IS NOT NULL
 		BEGIN	
 			INSERT INTO #curve_source_value_list(curve_source_value_id)
 			SELECT CAST(Item AS INT) curve_source_value_id FROM  dbo.SplitCommaSeperatedValues(@curve_source_value_id)
 		END;
		
		WITH T(date) AS (
            SELECT CAST(@as_of_date_from AS DATETIME)
            UNION ALL
            SELECT DATEADD(DAY, 1, T.date)
            FROM   T
            WHERE  T.date < CAST(@as_of_date_to AS DATETIME)
        )        
        SELECT ROW_NUMBER() OVER(ORDER BY dbo.FNAdateformat(date)) AS row_ord,
               [date] INTO #as_of_date
        FROM   T OPTION(MAXRECURSION 32767);
		
		;WITH T(date_from, date_to) AS
		(	SELECT CAST(@term_from AS DATETIME) date_from, CAST(@term_from AS DATETIME) date_to
			UNION ALL
			SELECT CASE WHEN T.date_to = @term_to THEN DATEADD(MONTH, 1, T.date_from) ELSE T.date_from END date_from, CASE WHEN T.date_to = @term_to THEN CAST(@term_from AS DATETIME) ELSE DATEADD(MONTH, 1, T.date_to) END date_to
			FROM   T
			WHERE CASE WHEN T.date_to = @term_to THEN DATEADD(MONTH, 1, T.date_from) ELSE T.date_from END <= CAST(@term_to AS DATETIME) 
		)
		SELECT ROW_NUMBER() OVER(ORDER BY dbo.FNAdateformat(date_from)) AS row_ord,
				date_from, date_to INTO #term_date_combo
		FROM   T OPTION(MAXRECURSION 32767);
		
		EXEC(@sql_term_date)

		SELECT rbf.curve_id_from,
			   spcd2.curve_id_to,
			   b.[date] as_of_date,
			   CONVERT(VARCHAR, dbo.Fnadateformat(date), 101) + ':::' + a.code + ':::' + spcd.curve_name + ' :: ' + spcd2.curve_name AS column_header,
			   a.curve_source_value_id
		INTO   #temp_header_list_old 
		FROM   #risk_bucket_from rbf 
			   INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = rbf.curve_id_from 
			   CROSS APPLY (SELECT rbt.curve_id_to, 
								   spcd1.curve_name
							FROM   #risk_bucket_to rbt 
								   INNER JOIN source_price_curve_def spcd1
											ON spcd1.source_curve_def_id = rbt.curve_id_to) spcd2
			   CROSS APPLY (SELECT csvl.curve_source_value_id, 
								   sdv.code 
							FROM   #curve_source_value_list csvl 
								   INNER JOIN static_data_value sdv 
										   ON sdv.value_id = csvl.curve_source_value_id) a 
			   CROSS APPLY(SELECT date 
						   FROM   #as_of_date) b 

		SELECT DISTINCT thlo.curve_id_from, thlo.curve_id_to, thlo.as_of_date, thlo.column_header, thlo.curve_source_value_id
 		INTO #temp_header_list
 		FROM #temp_header_list_old thlo 
 			 LEFT JOIN curve_correlation cc 
				ON cc.curve_id_from = thlo.curve_id_from AND cc.curve_id_to = thlo.curve_id_to
 		WHERE 1 = 1 ORDER BY thlo.as_of_date, thlo.curve_source_value_id

		SET @sql = 'INSERT INTO #curve_correlation_column_header(as_of_date, curve_id_from, curve_id_to, term1, term2, curve_value, curve_source_value_id, column_header)
					SELECT 
							CAST(dbo.FNAGetSQLStandardDate(cc.as_of_date) AS VARCHAR(10)),
 							--Convert(VARCHAR(12),cc.as_of_date,101),
 							cc.curve_id_from,
 							cc.curve_id_to,
 							Convert(VARCHAR(12),cc.term1,101),
 							Convert(VARCHAR(12),cc.term2,101),
							' + CASE WHEN NULLIF(@round_value,'') IS NOT NULL THEN 'ROUND(cc.value, ' + @round_value+ ')' ELSE 'cc.value' END + ' as curve_value,
 							cc.curve_source_value_id,
 							CONVERT(VARCHAR, dbo.Fnadateformat(cc.as_of_date), 101) + '':::'' + sdv.code + '':::'' + spcd.curve_name + ''::'' + spcd2.curve_name AS column_header			
 					FROM curve_correlation cc
							INNER JOIN #risk_bucket_from rbf ON rbf.curve_id_from = cc.curve_id_from
							INNER JOIN #risk_bucket_to rbt ON rbt.curve_id_to = cc.curve_id_to
							INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = rbf.curve_id_from
							INNER JOIN source_price_curve_def spcd2 ON spcd2.source_curve_def_id = rbt.curve_id_to
							INNER JOIN #curve_source_value_list csvl ON csvl.curve_source_value_id = cc.curve_source_value_id
							INNER JOIN static_data_value sdv ON sdv.value_id = csvl.curve_source_value_id 														
 					'

		SET @where_sql = @where_sql + CASE WHEN NULLIF(@as_of_date_from, '') IS NOT NULL  
												THEN ' AND cc.as_of_date >= '+''''+ @as_of_date_from +'''' ELSE '' END
 									+ CASE WHEN NULLIF(@as_of_date_to, '') IS NOT NULL 
												THEN ' AND cc.as_of_date <= '+''''+ @as_of_date_to +''''   ELSE '' END
 									+ CASE WHEN NULLIF(@term_from, '') IS NOT NULL 
												THEN ' AND cc.term1 >= '+''''+ @term_from  +'''' ELSE '' END	  
 									+ CASE WHEN NULLIF(@term_to, '') IS NOT NULL 
												THEN ' AND cc.term1 <= '+''''+ @term_to +''''  ELSE '' END
									+ CASE WHEN NULLIF(@term_from, '') IS NOT NULL 
												THEN ' AND cc.term2 >= '+''''+ @term_from  +'''' ELSE '' END	  
 									+ CASE WHEN NULLIF(@term_to, '') IS NOT NULL 
												THEN ' AND cc.term2 <= '+''''+ @term_to +''''  ELSE '' END
 						
 		SET @order_sql = ' ORDER BY cc.curve_id_from ASC'
		--PRINT (@sql + @where_sql + @order_sql)
		EXEC(@sql + @where_sql + @order_sql)
		--RETURN
		SELECT @curve_source_column_list = @curve_source_column_list + 
 				CASE WHEN  @curve_source_column_list = '' THEN  
 					+'[' + column_header +']' 
 				ELSE ','+'[' + column_header +']'
 				END  
 		FROM #temp_header_list ORDER BY as_of_date, curve_source_value_id, column_header

		SELECT
 			ISNULL(thl.as_of_date,ccch.as_of_date) as_of_date,
			thl.curve_id_from,
			thl.curve_id_to,
			ccch.term1,
			ccch.term2,
			ccch.curve_value,
			thl.curve_source_value_id,
			thl.column_header
 		INTO #curve_detail_data
 		FROM 
 			#temp_header_list thl
 			LEFT JOIN #curve_correlation_column_header ccch 
 				ON ISNULL(thl.as_of_date,ccch.as_of_date) = ccch.as_of_date 
 					AND thl.curve_id_from = ccch.curve_id_from
 					AND thl.curve_id_to = ccch.curve_id_to
 					AND thl.curve_source_value_id = ccch.curve_source_value_id
			
		ORDER BY ccch.term1

		SELECT  
			tdc.row_ord, 
			tdc.date_from, 
			tdc.date_to, 
			thl.column_header column_header1, 
			thl.curve_id_from curve_id_from1, 
			thl.curve_id_to curve_id_to1
		INTO #term_date_combo_header 
		FROM #term_date_combo tdc 
			LEFT JOIN #temp_header_list thl ON 1=1

		--SELECT * FROM #temp_header_list
		--SELECT * FROM #curve_detail_data
		--SELECT * FROM #term_date_combo_header
							
		SET @pivot_query_sql1 = ''
 		SET @pivot_query_sql2 = ''
 		SET @pivot_query_sql1 = 'SELECT * INTO '+ @process_table + ' 
 								 FROM ( 
 										SELECT 
 											row_ord,
 											dbo.FNAdateformat(tdc.date_from) AS [Term From],
 											dbo.FNAdateformat(tdc.date_to) AS [Term To],
 											column_header1,
											CASE WHEN curve_value IS NULL THEN 
												CASE WHEN dbo.FNAdateformat(tdc.date_from) = dbo.FNAdateformat(tdc.date_to) THEN 
													CASE WHEN curve_id_from1 = curve_id_to1 THEN 1 END
												ELSE 
													NULL 
												END 
											ELSE 
												curve_value 
											END curve_value
 										FROM 
											#term_date_combo_header tdc 											
											LEFT JOIN #curve_detail_data cdd ON 
											tdc.date_from = cdd.term1 AND tdc.date_to = cdd.term2 AND tdc.column_header1 = cdd.column_header
											WHERE 1 = 1' +
											+ CASE WHEN @is_term_null = 1
													THEN ' AND curve_value is NOT NULL'  ELSE '' END	
 									+ ') up
 								PIVOT (AVG(curve_value) FOR column_header1 IN (
								'

 		SET @pivot_query_sql2 = ISNULL(@curve_source_column_list,'')+')) AS PVT'
		
		EXEC(@pivot_query_sql1+@pivot_query_sql2)

		--PRINT (@as_of_date_from)
		--PRINT(@pivot_query_sql1)
		--PRINT(@pivot_query_sql1+@pivot_query_sql2)
		--EXEC('select * from ' + @process_table)

		SET @sql =  'SELECT ROW_NUMBER() OVER (ORDER BY column_id) a , * 
					 FROM (
							SELECT c.name, ' + '''' + @process_id + '''' + ' as process_id, c.column_id,
 									CASE WHEN c.name = ''Term From'' THEN ''a_1''
 									WHEN c.name = ''Term To'' THEN ''a_2''
 									ELSE ''a_5'' END a2
 							FROM adiha_process.sys.[columns] c WITH(NOLOCK)
							INNER JOIN adiha_process.sys.tables t WITH(NOLOCK) ON t.object_id = c.object_id   
							WHERE t.name  = ' + '''' + @table_name + '''
						 ) a1
				     WHERE name <> ''row_ord''
					'
 			
 		EXEC(@sql)

	END
	ELSE
	BEGIN 
		SET @ParmDefinition = N' @head varchar(MAX) OUTPUT';	
 		SET @header_query_1 =  '
 								IF OBJECT_ID(N''tempdb..#temp_table'') IS NOT NULL
 									DROP TABLE #temp_table
 			
								SELECT ROW_NUMBER() OVER (ORDER BY name,column_id) a  ,* INTO #temp_table FROM ('+
 								'SELECT c.name, ' + 
										''''+@process_id + '''' +' as process_id,
										c.column_id,
 										CASE WHEN c.name = ''Term From'' THEN ''a_1''
											 WHEN c.name = ''Term To'' THEN ''a_2''
 										ELSE ''a_5'' END a2
 								FROM adiha_process.sys.[columns] c WITH(NOLOCK)
								INNER JOIN adiha_process.sys.tables t WITH(NOLOCK) ON t.object_id = c.object_id   
								WHERE t.name  = ' + '''' + @table_name + ''''
 				
 		SET @header_query_1= @header_query_1+ ') a1  ORDER BY a2
 			SET @head = ''''
 			SELECT @head= @head + CASE WHEN name  <> ''Row_ord'' THEN  CASE WHEN @head = '''' THEN +''[''+ name +'']'' ELSE +'',[''+ name +'']'' END ELSE '''' END     FROM #temp_table ORDER BY a2, column_id
 		'
 		
 		EXEC sp_executesql @header_query_1,@ParmDefinition, @head=@header_list OUTPUT;
	
 		EXEC('SELECT '+ @header_list+ ' FROM '+@process_table + ' WHERE [Term From] IS NOT NULL ORDER BY (CONVERT(DATE, [Term From])), (CONVERT(DATE, [Term To]))')
		
	END
END
ELSE	
IF @flag = 'i'
BEGIN
	BEGIN TRY
    	DECLARE @insert_grid_xml VARCHAR(MAX)
    	DECLARE @object_id VARCHAR(100)
    	DECLARE @grid_xml_table_name VARCHAR(500) = ''
    	DECLARE @query_insert VARCHAR(MAX) = ''
    	
    	SET @xml = CONVERT(XML, @xml)

    	SELECT @insert_grid_xml = '<Root>' + CAST(col.query('.') AS VARCHAR(MAX)) + '</Root>'
    	FROM @xml.nodes('/Root/GridGroup/Grid') AS XMLDATA(col)

		IF @insert_grid_xml IS NOT NULL
    	BEGIN
			IF OBJECT_ID('tempdb..#grid_xml_process_table_name') IS NOT NULL
				DROP TABLE #grid_xml_process_table_name

    	    CREATE TABLE #grid_xml_process_table_name
    	    (
    	    	table_name VARCHAR(200) COLLATE DATABASE_DEFAULT 
    	    )

    	    INSERT INTO #grid_xml_process_table_name
    	    EXEC spa_parse_xml_file 'b', NULL, @insert_grid_xml
 	    
    	    SELECT @grid_xml_table_name = table_name
    	    FROM #grid_xml_process_table_name
			
			IF OBJECT_ID('tempdb..#temp_curve_correlation') IS NOT NULL
				DROP TABLE #temp_curve_correlation

    	    CREATE TABLE #temp_curve_correlation
    	    (
    	    	id						INT PRIMARY KEY IDENTITY(1, 1),
    	    	as_of_date				VARCHAR(120) COLLATE DATABASE_DEFAULT  NULL,
				curve_id_from			VARCHAR(120) COLLATE DATABASE_DEFAULT  NULL,
				curve_id_to				VARCHAR(120) COLLATE DATABASE_DEFAULT  NULL,
				term1					VARCHAR(120) COLLATE DATABASE_DEFAULT  NULL,
				term2					VARCHAR(120) COLLATE DATABASE_DEFAULT  NULL,
    	    	curve_source_value_id   INT NULL,
    	    	[value]					FLOAT NULL
    	    )

    	    SET @query_insert = 
    	        '    	    
    			INSERT INTO #temp_curve_correlation
    			  (
    				as_of_date,				
					curve_id_from,			
					curve_id_to,				
					term1,					
					term2,					
					curve_source_value_id,   
					[value]		
    			  )
    			SELECT CONVERT(VARCHAR, a.as_of_date, 101) [as_of_date],
    				   spcd1.source_curve_def_id,
    				   spcd2.source_curve_def_id,
    				   dbo.FNAGetSQLStandardDateTime(a.term1) term1,
    				   dbo.FNAGetSQLStandardDateTime(a.term2) term2,
    				   sdv.value_id,
					   CASE 
							WHEN a.[value] = '''' THEN NULL 
							ELSE a.[value] 
					   END [value]
    			FROM ' + @grid_xml_table_name +
    				' a
    				   INNER JOIN source_price_curve_def spcd1
    						ON  a.curve_id_from = spcd1.curve_name
					   INNER JOIN source_price_curve_def spcd2
    						ON  a.curve_id_to = spcd2.curve_name
					   INNER JOIN static_data_value sdv
							ON sdv.code = a.curve_source_value_id
							AND sdv.[type_id] = 10007
					   LEFT JOIN curve_correlation cc
						--	ON CONVERT(VARCHAR, cc.as_of_date, 101) = CONVERT(VARCHAR, a.as_of_date, 101)
						--	AND CONVERT(VARCHAR, cc.term1, 101) = CONVERT(VARCHAR, a.term1, 101)
						--	AND CONVERT(VARCHAR, cc.term2, 101) = CONVERT(VARCHAR, a.term2, 101)
						 ON cc.as_of_date_char = CONVERT(VARCHAR, a.as_of_date, 101)
							AND cc.term1_char = CONVERT(VARCHAR, a.term1, 101)
							AND cc.term2_char = CONVERT(VARCHAR, a.term2, 101)
							AND cc.curve_id_from = spcd1.source_curve_def_id
							AND cc.curve_id_to = spcd2.source_curve_def_id
							AND cc.curve_source_value_id = sdv.value_id
				'
    	    EXEC (@query_insert)
			
			DECLARE @ins_or_del FLOAT, @next_flag CHAR(1)
			SELECT @ins_or_del = [value] from #temp_curve_correlation
			--SELECT @ins_or_del AS [value]
			--RETURN
			IF @ins_or_del IS NULL OR @ins_or_del = ''
				SET @next_flag = 'd'
			ELSE
				SET @next_flag = 'i'
			--SELECT @next_flag AS [Next Flag]
			--RETURN
			IF @next_flag = 'i'
			BEGIN
			--Delete first
				DELETE cc
 				FROM #temp_curve_correlation a
 				INNER JOIN curve_correlation cc
					ON cc.as_of_date = a.as_of_date
					AND cc.curve_id_from = a.curve_id_from
					--AND cc.[value] = a.[value]
					AND cc.curve_id_to = a.curve_id_to
					AND cc.term1 = a.term1
					AND cc.term2 = a.term2
					AND cc.curve_source_value_id = a.curve_source_value_id

				--RETURN
				INSERT INTO curve_correlation (
					as_of_date,				
					curve_id_from,			
					curve_id_to,				
					term1,					
					term2,					
					curve_source_value_id,   
					[value]
				)
				SELECT as_of_date,				
					   curve_id_from,			
					   curve_id_to,				
					   term1,					
					   term2,					
					   curve_source_value_id,   
					   [value]
				FROM #temp_curve_correlation
				--WHERE insert_delete = 'i'

				SET @sql = dbo.FNAProcessDeleteTableSql(@grid_xml_table_name)
 				EXEC (@sql)
			END
			IF @next_flag = 'd'
			BEGIN
				DELETE cc
				FROM curve_correlation cc
 				INNER JOIN #temp_curve_correlation a
					ON cc.as_of_date = a.as_of_date
					AND cc.curve_id_from = a.curve_id_from
					AND cc.curve_id_to = a.curve_id_to
					AND cc.term1 = a.term1
					AND cc.term2 = a.term2
					AND cc.curve_source_value_id = a.curve_source_value_id
				WHERE a.value IS NULL
			END
    	END

		EXEC spa_ErrorHandler 0, 
 			'Process Form Data', 
 			'spa_view_correlation', 
 			'Success', 
 			'Changes have been saved successfully.',
 			''
	END TRY
	BEGIN CATCH
		DECLARE @error_id INT = ERROR_NUMBER()
    	DECLARE @err VARCHAR(1024) = ''
    	DECLARE @desc VARCHAR(MAX)
    	IF @error_id = 2627
    	BEGIN
    	    SET @err = ERROR_MESSAGE();
    	    IF @error_id = 2627 --Unique Constraint
    	    BEGIN
    	        SET @table_name = 'curve_correlation'
    	        SET @err = 
    	            'Error Occurred<a href="#" onclick="$(this).next(''div'').toggle();"><br/><font size=1>Technical Details.</font></a>'
    	        
    	        SET @err += 
    	            '<div style="font-size:10px;color:red;display:none;" id="target">' 
    	            + ERROR_MESSAGE() + '</div>'
    	    END
    	    ELSE
    	        SET @desc = dbo.FNAHandleDBError('10000000')
    	    
    	    EXEC spa_ErrorHandler -1,
    	         'Process Form Data',
    	         'spa_view_correlation',
    	         'Error',
    	         @desc,
    	         ''
    	END
	END CATCH

END
ELSE
IF @flag = 'd'
BEGIN
	BEGIN TRY
    	DECLARE @delete_xml VARCHAR(MAX)
    	DECLARE @delete_table VARCHAR(MAX)
    	DECLARE @delete_xml_table_name VARCHAR(500) = ''
		DECLARE @query_delete VARCHAR(MAX) = ''
		DECLARE @curve_source_value_id_del VARCHAR(20)
    	
    	SET @xml = CONVERT(XML, @xml)
		    	
    	SELECT @delete_xml = '<Root>' + CAST(col.query('.') AS VARCHAR(MAX)) + '</Root>'
    	FROM @xml.nodes('/Root/GridGroup/GridDelete') AS XMLDATA(col)

		IF @delete_xml IS NOT NULL
    	BEGIN
			IF OBJECT_ID('tempdb..#delete_xml_process_table_name') IS NOT NULL
				DROP TABLE #delete_xml_process_table_name

			CREATE TABLE #delete_xml_process_table_name
			(
				table_name VARCHAR(200) COLLATE DATABASE_DEFAULT  
			)

 			INSERT INTO #delete_xml_process_table_name 
			EXEC spa_parse_xml_file 'b', NULL, @delete_xml
		
			SELECT @delete_xml_table_name = table_name FROM #delete_xml_process_table_name

			SET @query_delete = '
			DELETE cc
 			FROM ' +  @delete_xml_table_name + ' a
 			INNER JOIN curve_correlation cc
				ON cc.as_of_date = a.as_of_date
				AND cc.curve_id_from = a.curve_id_from
				AND cc.curve_id_to = a.curve_id_to
				AND cc.term1 = a.term1
				AND cc.term2 = a.term2
				AND cc.curve_source_value_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(a.curve_source_value_id))
 			'

 			EXEC(@query_delete)

 			SET @sql = dbo.FNAProcessDeleteTableSql(@delete_xml_table_name)
 			EXEC (@sql)
		END

		EXEC spa_ErrorHandler 0,
 			'Process Form Data', 
 			'spa_view_correlation', 
 			'Success', 
 			'Changes have been saved successfully.',
 			''
	END TRY
	BEGIN CATCH
		DECLARE @error_id_del INT = ERROR_NUMBER()
    	DECLARE @err_del VARCHAR(1024) = ''
    	DECLARE @desc_del VARCHAR(MAX)
    	IF @error_id_del = 2627
    	BEGIN
    	    SET @err_del = ERROR_MESSAGE();
    	    IF @error_id_del = 2627 --Unique Constraint
    	    BEGIN
    	        SET @table_name = 'curve_correlation'
    	        SET @err_del = 
    	            'Error Occurred<a href="#" onclick="$(this).next(''div'').toggle();"><br/><font size=1>Technical Details.</font></a>'
    	        
    	        SET @err_del += 
    	            '<div style="font-size:10px;color:red;display:none;" id="target">' 
    	            + ERROR_MESSAGE() + '</div>'
    	    END
    	    ELSE
    	        SET @desc_del = dbo.FNAHandleDBError('10000000')
    	    
    	    EXEC spa_ErrorHandler -1,
    	         'Process Form Data',
    	         'spa_view_correlation',
    	         'Error',
    	         @desc_del,
    	         ''
    	END
	END CATCH
END
ELSE
IF @flag = 'p' 
BEGIN
	
	IF @term_from IS NOT NULL
	BEGIN
		SET @term_from = (SELECT DATEADD(m, DATEDIFF(m, 0, @term_from), 0));
		SET @term_from = CONVERT(DATE, @term_from);
	END

	IF @term_to IS NOT NULL
	BEGIN
		SET @term_to = (SELECT DATEADD(m, DATEDIFF(m, 0, @term_to), 0));
		SET @term_to = CONVERT(DATE, @term_to);
	END

	IF @as_of_date_to IS NOT NULL
	BEGIN
		SET @as_of_date_to = @as_of_date_from
	END
	
	SET @select_sql = '
						SELECT 
							cc.id [ID], 
							spcd.curve_name [Curve ID From],
							spcd2.curve_name [Curve ID To],
							dbo.FNADateFormat(cc.term1) [Term From],
							dbo.FNADateFormat(cc.term2) [Term To],
							dbo.FNADateFormat(cc.as_of_date) [As of Date],
							sdv.code [Curve Source], 
							cc.value [Curve Value]'+ @str_batch_table +'
						FROM curve_correlation cc
						INNER JOIN source_price_curve_def spcd ON cc.curve_id_from = spcd.source_curve_def_id 
						INNER JOIN source_price_curve_def spcd2 ON cc.curve_id_to = spcd2.source_curve_def_id 
						LEFT JOIN static_data_value sdv ON sdv.value_id = cc.curve_source_value_id
					'

	IF @curve_id_from IS NOT NULL AND @curve_id_from <> ''
		SET @select_sql += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @curve_id_from + ''') a ON cc.curve_id_from = a.item'

	IF @curve_id_to IS NOT NULL AND @curve_id_to <> ''
		SET @select_sql += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @curve_id_to + ''') b ON cc.curve_id_to = b.item'

	IF @curve_source_value_id IS NOT NULL  AND @curve_source_value_id <> ''
		SET @select_sql += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @curve_source_value_id + ''') c ON cc.curve_source_value_id = c.item'
	
	SET @select_sql += ' WHERE 1 =1 '
	
	IF @as_of_date_from IS NOT NULL  AND @as_of_date_from <> ''
		SET @select_sql += ' AND cc.as_of_date >= ''' + @as_of_date_from + ''''

	IF @as_of_date_to IS NOT NULL  AND @as_of_date_to <> ''
		SET @select_sql += ' AND cc.as_of_date <= ''' + @as_of_date_to + ''''

	IF @term_from IS NOT NULL  AND @term_from <> ''
		SET @select_sql += ' AND cc.term1 BETWEEN ''' + @term_from + ''' AND ''' + @term_to + ''''

	IF @term_to IS NOT NULL  AND @term_to <> ''
		SET @select_sql += ' AND cc.term2 BETWEEN ''' + @term_from + ''' AND ''' + @term_to + ''''
	
	SET @order_sql = ' ORDER BY [Curve Source], [Term From], [Term To] ASC' 

	--PRINT(@select_sql + @order_sql) 
	EXEC(@select_sql + @order_sql)
END

/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board 
IF @is_batch = 1 
BEGIN 
	SELECT @str_batch_table = dbo.FNABatchProcess ('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)  
	EXEC (@str_batch_table) 
	SELECT @str_batch_table = dbo.FNABatchProcess ('c', @batch_process_id, @batch_report_param, 
				   GETDATE(), 'spa_view_correlation', 'View Correlation') --TODO: modify sp and report name 
	EXEC (@str_batch_table) 
	RETURN 
END 
--if it is first call from paging, return total no. of rows and process id instead of actual data 
IF @enable_paging = 1 AND @page_no IS NULL 
BEGIN 
	SET @sql_paging = dbo.FNAPagingProcess ('t', @batch_process_id, @page_size, @page_no) 
	EXEC (@sql_paging) 
END 
/*******************************************2nd Paging Batch END**********************************************/
