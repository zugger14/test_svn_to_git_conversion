 IF OBJECT_ID(N'[dbo].[spa_view_volatility]', N'P') IS NOT NULL
   DROP PROCEDURE [dbo].spa_view_volatility
 
 SET ANSI_NULLS ON
 GO
 
 SET QUOTED_IDENTIFIER ON
 GO
 
 
 CREATE PROCEDURE [dbo].[spa_view_volatility]
 	@flag CHAR(1) = Null,
 	@xml XML= NULL,
 	@source_price_curve VARCHAR(max) = NULL,
 	@curve_source_value VARCHAR(1000) = NULL,
 	@as_of_date_from VARCHAR(20) = NULL,
 	@as_of_date_to VARCHAR(20) = NULL,
 	@tenor_from VARCHAR(20) = NULL,
 	@tenor_to VARCHAR(20) = NULL,
 	@forward_settle CHAR(1) = 'f',
 	@round_value VARCHAR(10) = 4,
 	@process_id VARCHAR(200) = NULL,
 	@granularity VARCHAR(20) = 'monthly',
	@granularity_id VARCHAR(20) = NULL,
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,		--'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
 AS
 
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
 DECLARE @desc VARCHAR(500) = ''
 DECLARE @delete_xml_table_name VARCHAR(500) = '';
 DECLARE @ParmDefinition nVARCHAR(500) = ''
 DECLARE @header_query_1 nVarchar(MAX)
 DECLARE @header_list nVARCHAR(MAX) = ''
 DECLARE @select_sql VARCHAR(MAX)
 DECLARE @time_zone VARCHAR(100)



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
 
 DECLARE @process_table VARCHAR(500) = dbo.FNAProcessTableName('view_volatility',dbo.FNADBUser(),@process_id)
 
 SELECT @table_name =  REPLACE(@process_table, 'adiha_process.dbo.', '')

SET @as_of_date_from = NULLIF(@as_of_date_from,'')
SET @as_of_date_to = NULLIF(@as_of_date_to,'')

 --view volatility doesnot exists for lower granularity i.e less than daily
SELECT @granularity = CASE 
		WHEN @granularity_id = '980' OR  @granularity_id = '10000289' THEN 'm' --Monthly or TOU Monthly
		WHEN @granularity_id = '991' THEN  'q' --Quarterly
		WHEN @granularity_id = '992' THEN  's' --Semi-Annually
		WHEN @granularity_id = '993' THEN  'a' -- Annually
	ELSE
		LEFT(@granularity,1)
END

IF @as_of_date_from IS NULL -- Checking the maximim as_of_date
BEGIN
	SET @as_of_date_from = (SELECT CAST(dbo.FNAGetSQLStandardDate(MAX(as_of_date)) AS VARCHAR(20)) 
								FROM curve_volatility cv
								INNER JOIN source_price_curve_def spcd ON cv.curve_id = spcd.source_curve_def_id 
								inner JOIN static_data_value sdv ON sdv.value_id = cv.curve_source_value_id
								INNER JOIN dbo.SplitCommaSeperatedValues(@source_price_curve) a ON cv.curve_id = a.item
								INNER JOIN dbo.SplitCommaSeperatedValues(@curve_source_value) b ON cv.curve_source_value_id = b.item
							)
	SET @as_of_date_to = (SELECT @as_of_date_from)
	IF @as_of_date_to IS NULL
	BEGIN
		SET @as_of_date_to = (SELECT @as_of_date_from)
	END
END

IF @as_of_date_from IS NULL
BEGIN
	SET @as_of_date_from = GETDATE();
END

IF @as_of_date_to IS NULL
BEGIN
	SET @as_of_date_to = @as_of_date_from
END
 
 IF @flag='s'
 BEGIN		

 	SET @as_of_date_from = ISNULL(@as_of_date_from,@tenor_from)
 	IF @header_detail = 'h' 
 	BEGIN
 		SET @where_sql = ' WHERE 1 = 1'
 		CREATE TABLE #source_price_curve_list(
 			rowID int not null identity(1,1),
 			price_curve_id INT,
 			UNIQUE(price_curve_id) 
 		)
 		CREATE TABLE #curve_source_value_list(
 			rowID int not null identity(1,1),
 			curve_source_id INT
 			UNIQUE(curve_source_id)
 			)
 
 		CREATE TABLE #overall( 
 				value VARCHAR(1000) COLLATE DATABASE_DEFAULT ,
 				as_of_date VARCHAR(20) COLLATE DATABASE_DEFAULT ,
 				curve_name VARCHAR(50) COLLATE DATABASE_DEFAULT 
 			)
 
 		CREATE TABLE #price_curve_column_header(	
 				row_id INT IDENTITY(1,1),
 				source_curve_def_id INT,
 				curve_name VARCHAR(100) COLLATE DATABASE_DEFAULT ,
 				curve_value FLOAT,
 				as_of_date VARCHAR(12) COLLATE DATABASE_DEFAULT ,
 				maturity_date VARCHAR(12) COLLATE DATABASE_DEFAULT ,
 				curve_source_value_id INT,
 				column_header VARCHAR(200) COLLATE DATABASE_DEFAULT 
 			)
 
 		IF @source_price_curve IS NOT NULL
 		BEGIN	
 			INSERT INTO #source_price_curve_list(price_curve_id)
 			SELECT CAST(Item AS INT) price_curve_id FROM  dbo.SplitCommaSeperatedValues(@source_price_curve)
 		END;

		SELECT
		top 1 @time_zone = tz.dst_group_value_id
		FROM source_price_curve_def spcd
			INNER JOIN time_zones tz ON spcd.time_zone = tz.TIMEZONE_ID
			INNER JOIN #source_price_curve_list spcl ON spcd.source_curve_def_id = spcl.price_curve_id
			
		DECLARE @tenor_status INT
		IF @tenor_from =''
		BEGIN
			set @tenor_status = NULL
		END
		ELSE
		BEGIN
			SET @tenor_status = 1
		END

 		IF @tenor_from =''
 		BEGIN
 			SELECT @tenor_from =CONVERT(DATETIME,MIN(term),103) FROM curve_volatility cv INNER JOIN #source_price_curve_list spcl 
 			ON cv.curve_id = spcl.price_curve_id 
 			WHERE 
 				as_of_date >= @as_of_date_from 
 	
 		END
		
		SET @tenor_from = (SELECT DATEADD(mm, DATEDIFF(mm, 0, @tenor_from), 0))

		--IF NOT EXISTS(SELECT 1 FROM curve_volatility 
		--	WHERE as_of_date = @as_of_date_from
		--AND term = @tenor_from) 
		--BEGIN
		--	SET @tenor_from = NULL;
		--END
 	
 		IF @tenor_to = '' 
 		BEGIN
 		SELECT @tenor_to = MAX(term)
 		 FROM curve_volatility cv
 			INNER JOIN #source_price_curve_list spcl 
 			ON cv.curve_id = spcl.price_curve_id 
 			WHERE 
 			as_of_date >=@as_of_date_from
 
 		END 
 		
 
 		SET @as_of_date_to =coalesce(@as_of_date_to,@tenor_to,@tenor_from)
 
 		;WITH T(date)
 		AS
 		( 
 		SELECT CAST(@as_of_date_from As datetime)
 		UNION ALL
 		SELECT DateAdd(day,1,T.date) FROM T WHERE T.date < CAST(@as_of_date_to As datetime)
 		)
 		SELECT date INTO #as_of_date FROM T OPTION (MAXRECURSION 32767);
 	
 		IF @curve_source_value IS NOT NULL
 		BEGIN	
 			INSERT INTO #curve_source_value_list(curve_source_id)
 			SELECT CAST(Item AS INT) price_curve_id FROM  dbo.SplitCommaSeperatedValues(@curve_source_value)
 		END	
 
 		SELECT ROW_NUMBER() OVER (ORDER BY dbo.FNAdateformat(term_start)) as row_ord,CONVERT(date,term_start) as Maturity_date, term_end as maturity_date_end
 		INTO  #maturity_date_list 
 		FROM dbo.FNATermBreakdownDST(@granularity,@tenor_from,@tenor_to,ISNULL(@time_zone,102200))
 
 
 		SELECT  spcd.source_curve_def_id,
 				b.date as_of_date,
 				CONVERT(VARCHAR,dbo.FNADateformat(date),101)+'::' + spcd.curve_name +'::'+a.code column_header,
 				a.curve_source_id curve_source_id				
 		INTO #temp_header_list_old
 		FROM #source_price_curve_list spcl  
 			INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = spcl.price_curve_id
 			CROSS APPLY(SELECT csvl.curve_source_id,sdv.code FROM #curve_source_value_list csvl 
 			INNER JOIN static_data_value sdv ON sdv.value_id = csvl.curve_source_id AND sdv.type_id = 10007) a 
 			CROSS APPLY(SELECT date FROM #as_of_date) b
 
 
 		SELECT thl.source_curve_def_id,as_of_date,column_header,curve_source_id
 		INTO  #temp_header_list
 		FROM #temp_header_list_old thl 
 			LEFT JOIN source_price_curve_def spcd 
 				on spcd.source_curve_def_id = thl.source_curve_def_id
 		WHERE 1=1
 
 	
 	SET @sql = ' INSERT INTO #price_curve_column_header(source_curve_def_id,curve_name,curve_value,as_of_date,maturity_date,curve_source_value_id,column_header)
 				SELECT 
 					spcd.source_curve_def_id,
 					spcd.curve_name,
					' + CASE WHEN NULLIF(@round_value,'') IS NOT NULL THEN 'ROUND(cv.~value~, ' + @round_value+ ')' ELSE 'cv.~value~' END + ' as curve_value,
 					Convert(VARCHAR(12),cv.as_of_date,101),
 					Convert(VARCHAR(12),cv.~term~,101),
 					cv.curve_source_value_id,
 					Convert(VARCHAR(12),dbo.FNADateFormat(cv.as_of_date),101)'+'+'+''''+'::'+''''+'+'+'spcd.curve_name'+'+'+''''+'::'+''''+'+'+'sdv.code AS column_header					
 			FROM 
 				source_price_curve_def spcd 
 				INNER JOIN #source_price_curve_list spcl
 					ON spcd.source_curve_def_id = spcl.price_curve_id
 					and isnull(spcd.derive_on_calculation,''n'')=''~y_n~''
 				INNER JOIN ~curve_volatility~ cv 
 					ON cv.~curve_id~ = spcl.price_curve_id
 					and cv.curve_source_value_id IN('+isnull(@curve_source_value,'4500')+')
 				LEFT JOIN static_data_value sdv ON cv.curve_source_value_id = sdv.value_id AND sdv.type_id = 10007
 				LEFT JOIN static_data_value sdv1 ON spcd.Granularity = sdv1.value_id and sdv1.type_id = 978
 				LEFT JOIN holiday_group hg ON hg.hol_group_value_id =spcd.exp_calendar_id
 					AND hg.hol_date = cv.~term~ AND hg.exp_date = cv.as_of_date
 				LEFT JOIN static_data_value sdv2 ON sdv2.value_id = hg.hol_group_value_id AND sdv2.type_id = 10017
 								
 				'
 		SET @where_sql = @where_sql +CASE WHEN @as_of_date_from IS NOT NULL  THEN ' AND cv.as_of_date >= '+''''+ @as_of_date_from +'''' ELSE '' END
 										+CASE  WHEN @as_of_date_to IS NOT NULL THEN ' AND cv.as_of_date <= '+''''+ @as_of_date_to +''''   ELSE '' END
 										+CASE  WHEN @tenor_from IS NOT NULL THEN ' AND cv.~term~ >= '+''''+ @tenor_from  +'''' ELSE '' END	  
 										+CASE  WHEN @tenor_to IS NOT NULL THEN ' AND cv.~term~ <= '+''''+ @tenor_to +''''  ELSE '' END
 									--	+CASE  WHEN @forward_settle IS NOT NULL AND @forward_settle IN('f','s') THEN ' AND ISNULL(spcd.forward_settle,'+''''+@forward_settle +''') = '+''''+@forward_settle+''''  ELSE '' END
 						
 		SET @order_sql = ' ORDER BY spcl.price_curve_id ASC'
 			
 		set @sql=REPLACE(@sql,'~y_n~','n')
 		set @sql=REPLACE(@sql,'~curve_volatility~','curve_volatility')
 		set @sql=REPLACE(@sql,'~curve_id~','curve_id')
 		set @sql=REPLACE(@sql,'~value~','value')
 		set @sql=REPLACE(@sql,'~term~','term')
 	
 		set @where_sql=REPLACE(@where_sql,'~term~','term')
 	
 		EXEC (@sql + @where_sql + @order_sql)
 
 		SELECT @curve_source_column_list = @curve_source_column_list + 
 				CASE WHEN  @curve_source_column_list = '' THEN  
 					+'[' + column_header +']' 
 				ELSE ','+'[' + column_header +']'
 				END  
 		FROM #temp_header_list	 order by as_of_date,column_header,source_curve_def_id
 
 		SELECT
 			pcch.maturity_date,
 			pcch.curve_value,
 			thl.source_curve_def_id,
 			ISNULL(thl.as_of_date,pcch.as_of_date)as_of_date,
 			thl.column_header
 		INTO #curve_detail_data
 		FROM 
 			#temp_header_list thl
 			LEFT JOIN #price_curve_column_header pcch 
 				ON ISNULL(thl.as_of_date,pcch.as_of_date) =pcch.as_of_date 
 				AND thl.source_curve_def_id = pcch.source_curve_def_id
 				AND pcch.curve_source_value_id = thl.curve_source_id
 	
 		SET @pivot_query_sql1 = ''
 		SET @pivot_query_sql2 = ''
 		SET @pivot_query_sql1 = 'SELECT * INTO '+ @process_table + ' 
 				FROM ( 
 						SELECT  
 							row_ord,
 							dbo.FNAdateformat(md.Maturity_date) as [Maturity Date],
 							column_header,
 							curve_value 
 						FROM '
 							+CASE  WHEN @tenor_status IS NOT NULL THEN ' #maturity_date_list md lEFT JOIN #curve_detail_data cdd ON cdd.maturity_date = md.Maturity_date' ELSE '#maturity_date_list md INNER JOIN #curve_detail_data cdd ON cdd.maturity_date = md.Maturity_date' END+
 					') up
 			PIVOT (AVG(curve_value) FOR column_header IN ('
 			SET @pivot_query_sql2 = ISNULL(@curve_source_column_list,'')+')) AS PVT'
 
 			EXEC(@pivot_query_sql1+@pivot_query_sql2)
 
 			SET @sql =  'SELECT ROW_NUMBER() OVER (ORDER BY column_id) a  ,* FROM (SELECT c.name, '+''''+@process_id+'''' +' as process_id,c.column_id,
 			CASE WHEN c.name = ''Maturity Date'' THEN ''a_1''
 					ELSE ''a_5'' END a2
 			FROM adiha_process.sys.[columns] c INNER JOIN adiha_process.sys.tables t on t.object_id = c.object_id   where t.name  ='+''''+@table_name+''') a1 WHERE name <> ''row_ord'''
 			
 			--PRINT @sql
 			EXEC(@sql)
 	END
 	ELSE 
 	BEGIN
 			SET @ParmDefinition = N' @head varchar(MAX) OUTPUT';
 
 			
 			SET @header_query_1 =  '
 			IF OBJECT_ID(N''tempdb..#temp_table'') IS NOT NULL
 				DROP TABLE #temp_table
 				SELECT ROW_NUMBER() OVER (ORDER BY name,column_id) a  ,* INTO #temp_table FROM ('+
 				'SELECT c.name, '+''''+@process_id+'''' +' as process_id,c.column_id,
 										CASE WHEN c.name = ''Maturity Date'' THEN ''a_1''
 											 ELSE ''a_5'' END a2
 										FROM adiha_process.sys.[columns] c INNER JOIN adiha_process.sys.tables t on t.object_id = c.object_id   where t.name  ='+''''+@table_name+''''
 				
 			SET @header_query_1= @header_query_1+ ') a1  order by a2
 				SET @head = ''''
 				SELECT @head= @head + CASE WHEN name  <> ''Row_ord'' THEN  CASE WHEN @head = '''' THEN +''[''+ name +'']'' ELSE +'',[''+ name +'']'' END ELSE '''' END     FROM #temp_table Order by a2,column_id
 			'
 			--print @header_query_1
 			EXEC sp_executesql @header_query_1,@ParmDefinition, @head=@header_list OUTPUT;
 
 			EXEC('SELECT '+ @header_list+ ' FROM '+@process_table + ' where [maturity date] IS NOT NULL ORDER BY dbo.FNAClientToSqlDate([Maturity Date])')
 
 	END
 END	
 
ELSE IF @flag = 'i'
BEGIN
 	BEGIN TRY
 		DECLARE @grid_xml  VARCHAR(MAX)
 		DECLARE @object_id VARCHAR(100)
 		DECLARE @delete_xml VARCHAR(MAX)
 		DECLARE @searchword VARCHAR(200)
 		DECLARE @grid_xml_table_name VARCHAR(500) = ''
 		DECLARE @query_insert VARCHAR(max) = ''
 			
 		SET @xml= Convert(xml,@xml)
 		SELECT @grid_xml = '<Root>'+CAST(col.query('.') AS VARCHAR(MAX))+'</Root>'
 			FROM @xml.nodes('/Root/GridGroup/Grid') AS xmlData(col)
 			
 		  
 			SELECT @delete_xml = '<Root>'+CAST(col.query('.') AS VARCHAR(MAX))+'</Root>'
 			FROM @xml.nodes('/Root/GridGroup/GridDelete') AS xmlData(col)  
 
 		---- parse the Object ID
 		SELECT
 			@object_id = xmlData.col.value('@object_id','VARCHAR(100)')
 		FROM
 			@xml.nodes('/Root') AS xmlData(Col)   
 
 	IF @grid_xml IS NOT NULL
 			BEGIN
 					
 					
 				CREATE TABLE #grid_xml_process_table_name(table_name VARCHAR(200) COLLATE DATABASE_DEFAULT  )
 				INSERT INTO #grid_xml_process_table_name EXEC spa_parse_xml_file 'b', NULL, @grid_xml
 					SELECT @grid_xml_table_name = table_name FROM #grid_xml_process_table_name
 	
 
 				CREATE TABLE #temp_price_curve(
 					id INT PRIMARY KEY IDENTITY(1,1),
 					as_of_date VARCHAR(12) COLLATE DATABASE_DEFAULT  NULL,
 					curve_source_value_id INT NULL,
 					curve_id INT NULL,
 					maturity_date  VARCHAR(25) COLLATE DATABASE_DEFAULT  NULL,
 					value FLOAT NULL,
 					insert_update CHAR(1) COLLATE DATABASE_DEFAULT  NULL,
 					forward_settle CHAR(1) COLLATE DATABASE_DEFAULT  NULL
 				)
 				--SELECT * FROM #temp_price_curve
 					
 					SET @query_insert = 'INSERT INTO #temp_price_curve(as_of_date,curve_source_value_id,curve_id,maturity_date,value,insert_update,forward_settle)'
 					SET @query_insert = @query_insert+ '
 					SELECT 
 						CONVERT(VARCHAR,a.as_of_date,101) as_of_date,
 						sdv.value_id,
 						spcd.source_curve_def_id,
 						dbo.FNAGetSQLStandardDateTime(a.maturity_date),
 						a.value,
 						CASE WHEN cv.id IS NULL THEN ''i'' ELSE ''u'' END insert_update,
 						a.forward_settle
 					FROM '+ @grid_xml_table_name + ' a
 					INNER JOIN source_price_curve_def spcd on spcd.curve_name =  a.source_price_curve
 					INNER JOIN static_data_value sdv On sdv.code = a.curve_source AND sdv.type_id = 10007
 					--LEFT JOIN curve_volatility cv ON dbo.FNADateFormat(cv.term) = dbo.FNADateFormat(a.maturity_date) 
 					--AND dbo.FNADateFormat(cv.as_of_date) = dbo.FNADateFormat(a.as_of_date) 
					LEFT JOIN curve_volatility cv ON CAST(cv.term AS DATE) = 
					                CAST(a.maturity_date AS DATE) 
 					AND CAST(cv.as_of_date AS DATE)  = CAST(a.as_of_date AS DATE)
 					AND cv.curve_source_value_id = sdv.value_id
 					AND cv.curve_id = spcd.source_curve_def_id
 					'
 					EXEC(@query_insert)
 					--SELECT * FROM #temp_price_curve
 				
					UPDATE cv
					SET cv.as_of_date = CONVERT(VARCHAR,t.as_of_date,103),
 						cv.curve_source_value_id = t.curve_source_value_id,
 						cv.curve_id = t.curve_id,
 						cv.term = CONVERT(VARCHAR,t.maturity_date,103),
 						cv.value = NULLIF(t.value,''),
 						cv.update_ts = getDate(),
						cv.update_user = dbo.FNADBUser()	
 					FROM #temp_price_curve t 
 					--INNER JOIN curve_volatility cv ON dbo.FNADateFormat(cv.term) = dbo.FNADateFormat(t.maturity_date)
 					--	AND	dbo.FNADateFormat(cv.as_of_date) = dbo.FNADateFormat(t.as_of_date)
					INNER JOIN curve_volatility cv ON CAST(cv.term AS DATE) = 
					                CAST(t.maturity_date AS DATE) 
 					AND CAST(cv.as_of_date AS DATE)  = CAST(t.as_of_date AS DATE)
 						AND cv.curve_id = t.curve_id
 						AND cv.curve_source_value_id = t.curve_source_value_id
 					WHERE t.insert_update = 'u'	

 					INSERT INTO curve_volatility(as_of_date,curve_source_value_id,curve_id,term,value,granularity,create_user,create_ts)
 					SELECT 
 						CONVERT(VARCHAR,as_of_date,103),
 						curve_source_value_id,
 						curve_id,
 						CONVERT(VARCHAR,maturity_date,103),
 						NULLIF(value,''),
						706,
 						dbo.FNADBUser(),
 						getdate()
 					FROM #temp_price_curve
 					WHERE insert_update = 'i'	
 						SET @sql = dbo.FNAProcessDeleteTableSql(@grid_xml_table_name)
 						EXEC (@sql)
 			END
 				
 			
 			IF @delete_xml IS NOT NULL 
 			BEGIN
 				CREATE TABLE #delete_xml_process_table_name(table_name VARCHAR(200) COLLATE DATABASE_DEFAULT  )
 				INSERT INTO #delete_xml_process_table_name EXEC spa_parse_xml_file 'b', NULL, @delete_xml
 					SELECT @delete_xml_table_name = table_name FROM #delete_xml_process_table_name
 					
 				SET @query_insert=''
 					
 				SET @query_insert = @query_insert+ 'DELETE cv 
 				FROM
 				'+ @delete_xml_table_name + ' a
 				INNER JOIN source_price_curve_def spcd on spcd.curve_name =  a.source_price_curve
				INNER JOIN static_data_value sdv On sdv.code = a.curve_source AND sdv.type_id = 10007
 				--LEFT JOIN curve_volatility cv ON 
 				--		dbo.FNADateFormat(cv.term) = dbo.FNADateFormat(a.maturity_date)
 				--		AND	dbo.FNADateFormat(cv.as_of_date) = dbo.FNADateFormat(a.as_of_date)
				LEFT JOIN curve_volatility cv ON CAST(cv.term AS DATE) = 
					                CAST(a.maturity_date AS DATE) 
 					AND CAST(cv.as_of_date AS DATE)  = CAST(a.as_of_date AS DATE)
						AND cv.curve_source_value_id = sdv.value_id
 				'
 			--print(@query_insert)
 			EXEC(@query_insert)
 					SET @sql = dbo.FNAProcessDeleteTableSql(@delete_xml_table_name)
 					EXEC (@sql)
 			END
 				EXEC spa_ErrorHandler 0, 
 				'Process Form Data', 
 				'spa_display_price_curve', 
 				'Success', 
 				'Changes have been saved successfully.',
 				''
 	END TRY
 	BEGIN CATCH
 		DECLARE @error_id INT = ERROR_NUMBER()
 		DECLARE @err VARCHAR(1024) = ''
 		DECLARE @start_index VARCHAR(1024)
 		DECLARE @constraint_name VARCHAR(1024)
 		IF @error_id =2627 
 		BEGIN
 				SET @err = ERROR_MESSAGE();
 				IF @error_id = 2627	--Unique Constraint
 				BEGIN
 					--SET @start_index = CHARINDEX('''',@err)	    
 					--SELECT  @constraint_name =  LEFT(SUBSTRING(@err,@start_index  + 1,LEN(@err)),CHARINDEX('''' , SUBSTRING(@err,@start_index  + 1,LEN(@err))) -1)
 					--	Find which table has been violated
 					SET @table_name = 'curve_volatility'
 					SET @err = 'Error Occurred<a href="#" onclick="$(this).next(''div'').toggle();"><br/><font size=1>Technical Details.</font></a>'		
 					SET @err += '<div style="font-size:10px;color:red;display:none;" id="target">' + ERROR_MESSAGE() + '</div>'
 						 
 
 				END
 			
 		ELSE 
 			SET @desc = dbo.FNAHandleDBError('10000000')
 			EXEC spa_ErrorHandler -1, 'Process Form Data', 
 						'spa_view_volatility', 'Error', 
 						@desc, ''
 		END
 	END CATCH
END
 		
IF @flag = 'p' -- For pivot
BEGIN
	SET @tenor_from = (SELECT DATEADD(mm, DATEDIFF(mm, 0, @tenor_from), 0))
	SET @select_sql = 'SELECT 
		cv.id [ID], 
		spcd.curve_id [Curve ID],
		spcd.curve_name [Curve Name],
		sdv.code [Curve Source], 
		dbo.FNADateFormat(cv.as_of_date) [As of Date], 
		dbo.FNADateFormat(cv.term) [Maturity Date],
		cv.value [Curve Value]'+ @str_batch_table +'
	FROM curve_volatility cv
	INNER JOIN source_price_curve_def spcd ON cv.curve_id = spcd.source_curve_def_id 
	LEFT JOIN static_data_value sdv ON sdv.value_id = cv.curve_source_value_id
	'

	IF @source_price_curve IS NOT NULL AND @source_price_curve <> ''
		SET @select_sql += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @source_price_curve + ''') a ON cv.curve_id = a.item'

	IF @curve_source_value IS NOT NULL  AND @curve_source_value <> ''
		SET @select_sql += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @curve_source_value + ''') b ON cv.curve_source_value_id = b.item'
	
	SET @select_sql += ' WHERE 1 =1 '
	
	IF @as_of_date_from IS NOT NULL  AND @as_of_date_from <> ''
		SET @select_sql += ' AND cv.as_of_date >= ''' + @as_of_date_from + ''''

	IF @as_of_date_to IS NOT NULL  AND @as_of_date_to <> ''
		SET @select_sql += ' AND cv.as_of_date <= ''' + @as_of_date_to + ''''

	IF @tenor_from IS NOT NULL  AND @tenor_from <> ''
		SET @select_sql += ' AND cv.term >= ''' + @tenor_from + ''''

	IF @tenor_to IS NOT NULL  AND @tenor_to <> ''
		SET @select_sql += ' AND cv.term <= ''' + @tenor_to + ''''

	SET @select_sql += ' AND DATEPART(d, cv.term) = 1' -- Retrieve data of first day.

	EXEC(@select_sql)
END


/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board
 
IF @is_batch = 1
 
BEGIN
 
	SELECT @str_batch_table = dbo.FNABatchProcess ('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
 
	EXEC (@str_batch_table)
 
	SELECT @str_batch_table = dbo.FNABatchProcess ('c', @batch_process_id, @batch_report_param, 
				   GETDATE(), 'spa_view_volatility', 'View Volatility') --TODO: modify sp and report name
 
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
 
GO
