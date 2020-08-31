IF OBJECT_ID(N'[dbo].[spa_view_default_probability]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].spa_view_default_probability
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_view_default_probability]	
	@flag				CHAR(1) = NULL,
	@xml				XML = NULL,
	@debt_rating		VARCHAR(MAX) = NULL,
	@as_of_date_from	VARCHAR(20) = NULL,
	@as_of_date_to		VARCHAR(20) = NULL,	
	@round_value		VARCHAR(10) = '4',
	@process_id			VARCHAR(200) = NULL,
	@show_months		VARCHAR(200) = NULL,
	@debug				CHAR(1) = 'n',

	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,		--'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
AS

SET NOCOUNT ON

/*
--# testing
DROP TABLE #default_probability_list
DROP TABLE #default_probability_header
DROP TABLE #default_probability_column_header
DROP TABLE #as_of_date
DROP TABLE #temp_header_list
DROP TABLE #detail_data

DECLARE @flag				CHAR(1) = NULL,
		@debt_rating		VARCHAR(MAX) = NULL,
		@as_of_date_from	VARCHAR(20) = NULL,
		@as_of_date_to		VARCHAR(20) = NULL,	
		@round_value		VARCHAR(10) = '4',
		@process_id			VARCHAR(200) = NULL,
		@debug				CHAR(1) = 'n'


SET @flag = 's'
SET @debt_rating = '303170,309153'
SET @as_of_date_from = '2010-01-01'
SET @as_of_date_to = '2010-03-01'
*/

DECLARE @header_detail CHAR(1)
DECLARE @sql VARCHAR(MAX)
DECLARE @where_sql VARCHAR(MAX)
DECLARE @select_sql VARCHAR(MAX)
DECLARE @column_list VARCHAR(MAX)
DECLARE @pivot_query_sql1 VARCHAR(MAX) = '' 
DECLARE @pivot_query_sql2 VARCHAR(MAX) = '' 
DECLARE @table_name VARCHAR(500)
DECLARE @ParmDefinition NVARCHAR(500) = ''
DECLARE @header_query_1 NVARCHAR(MAX)
DECLARE @header_list NVARCHAR(MAX) = ''


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

DECLARE @process_table VARCHAR(500) = dbo.FNAProcessTableName('view_default_probability', dbo.FNADBUser(), @process_id)

SELECT @table_name = REPLACE(@process_table, 'adiha_process.dbo.', '')

IF @flag = 't'
BEGIN
    SET @sql = 
        '
    SELECT sdt.[type_name],
           sdv.code,
           sdv.value_id,
           sdt.[type_id],
           sdv.[description]
    FROM   static_data_type sdt
           INNER JOIN static_data_value sdv
                ON  sdv.[type_id] = sdt.[type_id]
    WHERE  sdt.[type_id] IN (11099, 11100, 11101, 10097, 10098, 11102, 23000)
    ORDER BY
		sdt.[type_id], 
		sdv.code'
    
    IF @debug = 'y'
        PRINT @sql
    
    EXEC (@sql)
END
ELSE
IF @flag = 's'
BEGIN
    SET @as_of_date_from = NULLIF(@as_of_date_from, '')
    SET @as_of_date_to = NULLIF(@as_of_date_to, '')
    
    IF @header_detail = 'h'
    BEGIN
        SET @where_sql = ' WHERE 1 = 1'
        
        CREATE TABLE #default_probability_list
        (
        	rowID              INT NOT NULL IDENTITY(1, 1),
        	debt_rating_id     INT,
        	UNIQUE(debt_rating_id)
        ) 
        
        CREATE TABLE #default_probability_header
        (
        	rowID              INT NOT NULL IDENTITY(1, 1),
        	debt_rating_id     VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
        	probability_column        VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
        	months_column      VARCHAR(MAX) COLLATE DATABASE_DEFAULT
        )  
         
        CREATE TABLE #default_probability_column_header
        (
        	rowId              INT NOT NULL IDENTITY(1, 1),
        	debt_rating_id     INT,
        	debt_rating        VARCHAR(100) COLLATE DATABASE_DEFAULT,
        	VALUE              FLOAT,
        	effective_date     DATETIME,
        	[type]             CHAR(1) COLLATE DATABASE_DEFAULT,
        	column_header      VARCHAR(200) COLLATE DATABASE_DEFAULT
        )     
		        
        CREATE TABLE #temp_header_list
        (
        	debt_rating_id     INT,
        	column_header     VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
        	type        VARCHAR(MAX) COLLATE DATABASE_DEFAULT
		)

		SET @as_of_date_to = NULLIF(@as_of_date_to,'')
		IF @as_of_date_from IS NOT NULL AND @as_of_date_to IS NULL  -- IF ONLY 'AS_OF_DATE_FROM' IS GIVEN.
		BEGIN
			SET @as_of_date_to = @as_of_date_from
			IF NOT EXISTS (SELECT 1 FROM default_probability dp 
							INNER JOIN dbo.SplitCommaSeperatedValues(@debt_rating) rrl On dp.debt_rating = rrl.Item 
							INNER JOIN static_data_value sdv On sdv.value_id = dp.debt_rating
							WHERE dp.effective_date >= @as_of_date_from 
							AND dp.effective_date <= @as_of_date_to)
				BEGIN  -- IF DATA NOT FOUND IN SAME DATE THEN, DATA < AS_OF_DATE_FROM
					SET @as_of_date_from = (SELECT CAST(dbo.FNAGetSQLStandardDate(MAx(dp.effective_date)) AS VARCHAR(20)) 
												FROM default_probability dp 
											INNER JOIN dbo.SplitCommaSeperatedValues(@debt_rating) rrl On dp.debt_rating = rrl.Item 
											INNER JOIN static_data_value sdv On sdv.value_id = dp.debt_rating
											WHERE effective_date < @as_of_date_from)
					SET @as_of_date_to = (SELECT @as_of_date_from)
				END
		END

		IF @as_of_date_from IS NULL
		BEGIN
			SET @as_of_date_from = (SELECT CAST(dbo.FNAGetSQLStandardDate(MAX(dp.effective_date)) AS VARCHAR(20)) 
										FROM default_probability dp 
									INNER JOIN dbo.SplitCommaSeperatedValues(@debt_rating) rrl On dp.debt_rating = rrl.Item 
									INNER JOIN static_data_value sdv On sdv.value_id = dp.debt_rating)
			SET @as_of_date_to = (SELECT @as_of_date_from)
		END
        
        IF @debt_rating IS NOT NULL
        BEGIN
            INSERT INTO #default_probability_list
              (
                debt_rating_id
              )
            SELECT CAST(Item AS INT) debt_rating_id
            FROM   dbo.SplitCommaSeperatedValues(@debt_rating)
        END; 
        
		
        WITH T(date) AS (
            SELECT CAST(@as_of_date_from AS DATETIME)
            UNION ALL
            SELECT DATEADD(DAY, 1, T.date)
            FROM   T
            WHERE  T.date < CAST(@as_of_date_to AS DATETIME)
        )
        
		
        SELECT ROW_NUMBER() OVER(ORDER BY dbo.FNAdateformat(date)) AS row_ord,
               date AS as_of_date INTO #as_of_date
        FROM   T OPTION(MAXRECURSION 32767);
        
        SET @sql ='
		insert into #temp_header_list
        SELECT sdv.value_id debt_rating_id,
               sdv.code + ''::probability'' + ''::'' + CAST(sdv.value_id AS VARCHAR(20)) 
               column_header,
               ''r'' AS [type]                                             
        FROM   #default_probability_list rrl
               INNER JOIN static_data_value sdv
                    ON  sdv.value_id = rrl.debt_rating_id'
		--EXEC (@sql)

		IF @show_months = '1'
		BEGIN
			SET @sql +='
				UNION ALL
				SELECT sdv.value_id debt_rating_id,
					   sdv.code + ''::Month'' + ''::'' + CAST(sdv.value_id AS VARCHAR(20)) 
					   column_header,
					   ''m'' AS [type]
				FROM   #default_probability_list rrl
					   INNER JOIN static_data_value sdv
							ON  sdv.value_id = rrl.debt_rating_id'
			
		END
        EXEC (@sql)

        SET @sql = 
            'INSERT INTO #default_probability_column_header(debt_rating_id, debt_rating, value,effective_date,[type],column_header)
			SELECT 
				rrl.debt_rating_id,
				sdv.code,
				dp.probability,
				dp.effective_date,
				''r'' as [type],
				sdv.code+''::''+''Probability'' AS column_header
			FROM
				#default_probability_list rrl
				INNER JOIN default_probability dp On dp.debt_rating = rrl.debt_rating_id 
				INNER JOIN static_data_value sdv On sdv.value_id = dp.debt_rating
			WHERE 1=1 '
            + CASE 
                   WHEN @as_of_date_from IS NOT NULL THEN 
                        ' AND dp.effective_date >= ' + '''' + @as_of_date_from 
                        + ''''
                   ELSE ''
              END
            + CASE 
                   WHEN @as_of_date_to IS NOT NULL THEN 
                        ' AND dp.effective_date <= ' + '''' + @as_of_date_to +
                        ''''
                   ELSE ''
              END
            + ' ORDER BY rrl.debt_rating_id ASC'
        
        EXEC (@sql)
        
		IF @show_months = '1'
		BEGIN
        SET @sql = 
            'INSERT INTO #default_probability_column_header(debt_rating_id, debt_rating, value,effective_date,[type],column_header)
			SELECT 
				rrl.debt_rating_id,
				sdv.code,
				dp.months,
				dp.effective_date,
				''m'' as [type],
				sdv.code+''::''+''Months'' AS column_header
			FROM
				#default_probability_list rrl
				INNER JOIN default_probability dp On dp.debt_rating = rrl.debt_rating_id 
				INNER JOIN static_data_value sdv On sdv.value_id = dp.debt_rating
			WHERE 1=1 '
            + CASE 
                   WHEN @as_of_date_from IS NOT NULL THEN 
                        ' AND dp.effective_date >= ' + '''' + @as_of_date_from 
                        + ''''
                   ELSE ''
              END
            + CASE 
                   WHEN @as_of_date_to IS NOT NULL THEN 
                        ' AND dp.effective_date <= ' + '''' + @as_of_date_to +
                        ''''
                   ELSE ''
              END
            + ' ORDER BY rrl.debt_rating_id ASC'
        
        EXEC (@sql)
		END

        SET @column_list = ''
        SELECT @column_list = @column_list +
               CASE 
                    WHEN @column_list = '' THEN +'[' + column_header + ']'
                    ELSE ',' + '[' + column_header + ']'
               END
        FROM   #temp_header_list
        ORDER BY
               debt_rating_id,
               [type] DESC
        
        SELECT rrch.effective_date,
               rrch.value,
               thl.debt_rating_id,
               thl.column_header
               INTO #detail_data
        FROM   #temp_header_list thl
               LEFT JOIN #default_probability_column_header rrch
                    ON  thl.debt_rating_id = rrch.debt_rating_id
                    AND thl.[type] = rrch.[type]
        ORDER BY
               thl.debt_rating_id
        
        SET @pivot_query_sql1 = ''
        SET @pivot_query_sql2 = ''
        SET @pivot_query_sql1 = 'SELECT * INTO ' + @process_table +
            ' 
				FROM ( 
 						SELECT  
 							row_ord,
 							dbo.FNAdateformat(aod.as_of_date) as [Effective Date],
 							column_header,
 							' + CASE WHEN NULLIF(@round_value,'') IS NOT NULL THEN 'ROUND(value, ' + @round_value+ ')' ELSE 'value' END + ' value 
 						FROM 
 							#as_of_date aod 
							INNER JOIN #detail_data dd ON dd.effective_date = aod.as_of_date

 					) up
 			PIVOT (AVG(value) FOR column_header IN ('
        
        SET @pivot_query_sql2 = ISNULL(@column_list, '') + ')) AS PVT'
        
        EXEC (@pivot_query_sql1 + @pivot_query_sql2)
        
        SET @sql = 
            'SELECT ROW_NUMBER() OVER (ORDER BY column_id) a  ,* FROM (SELECT c.name, '
            + '''' + @process_id + '''' +
            ' as process_id,c.column_id,
 			CASE WHEN c.name = ''Effective Date'' THEN ''a_1''
 					ELSE ''a_5'' END a2
 			FROM adiha_process.sys.[columns] c INNER JOIN adiha_process.sys.tables t on t.object_id = c.object_id   where t.name  ='
            + '''' + @table_name + ''') a1 WHERE name <> ''row_ord'''
        
        EXEC (@sql)
    END
    ELSE
    BEGIN
        SET @ParmDefinition = N' @head varchar(MAX) OUTPUT'; 
        
        SET @header_query_1 = 
            '
 			IF OBJECT_ID(N''tempdb..#temp_table'') IS NOT NULL
 				DROP TABLE #temp_table
 				SELECT ROW_NUMBER() OVER (ORDER BY name,column_id) a  ,* INTO #temp_table FROM ('
            +
            'SELECT c.name, ' + '''' + @process_id + '''' +
            ' as process_id,c.column_id,
 										CASE WHEN c.name = ''Effective Date'' THEN ''a_1''
 											 ELSE ''a_5'' END a2
 										FROM adiha_process.sys.[columns] c INNER JOIN adiha_process.sys.tables t on t.object_id = c.object_id   where t.name  ='
            + '''' + @table_name + ''''
        
        SET @header_query_1 = @header_query_1 +
            ') a1  order by a2
 				SET @head = ''''
 				SELECT @head= @head + CASE WHEN name  <> ''Row_ord'' THEN  CASE WHEN @head = '''' THEN +''[''+ name +'']'' ELSE +'',[''+ name +'']'' END ELSE '''' END     FROM #temp_table Order by a2,column_id
 			'
        --print @header_query_1
        EXEC sp_executesql @header_query_1,
             @ParmDefinition,
             @head = @header_list OUTPUT;
        
        EXEC (
                 'SELECT ' + @header_list + ' FROM ' + @process_table +
                 ' where [Effective date] IS NOT NULL ORDER BY dbo.FNAClientToSqlDate([Effective Date])'
             )
    END
END
ELSE 
IF @flag = 'i'
BEGIN
    BEGIN TRY
    	DECLARE @grid_xml VARCHAR(MAX)
    	DECLARE @object_id VARCHAR(100)
    	DECLARE @delete_xml VARCHAR(MAX)
    	DECLARE @delete_table VARCHAR(MAX)
    	DECLARE @grid_xml_table_name VARCHAR(500) = ''
    	DECLARE @delete_xml_table_name VARCHAR(500) = ''
    	DECLARE @query_insert VARCHAR(MAX) = ''
    	
    	SET @xml = CONVERT(XML, @xml)
    	SELECT @grid_xml = '<Root>' + CAST(col.query('.') AS VARCHAR(MAX)) +
    	       '</Root>'
    	FROM   @xml.nodes('/Root/GridGroup/Grid') AS XMLDATA(col)
    	
    	
    	SELECT @delete_xml = '<Root>' + CAST(col.query('.') AS VARCHAR(MAX)) +
    	       '</Root>'
    	FROM   @xml.nodes('/Root/GridGroup/GridDelete') AS XMLDATA(col) 
    	
    	---- parse the Object ID
    	SELECT @object_id = XMLDATA.col.value('@object_id', 'VARCHAR(100)')
    	FROM   @xml.nodes('/Root') AS XMLDATA(Col)
    	
    	IF @grid_xml IS NOT NULL
    	BEGIN
    	    CREATE TABLE #grid_xml_process_table_name
    	    (
    	    	table_name VARCHAR(200) COLLATE DATABASE_DEFAULT
    	    )
    	    INSERT INTO #grid_xml_process_table_name
    	    EXEC spa_parse_xml_file 'b',
    	         NULL,
    	         @grid_xml
    	    
    	    SELECT @grid_xml_table_name = table_name
    	    FROM   #grid_xml_process_table_name
    	    
    	    CREATE TABLE #temp_default_probability
    	    (
    	    	id                 INT PRIMARY KEY IDENTITY(1, 1),
    	    	effective_date     VARCHAR(12) COLLATE DATABASE_DEFAULT NULL,
    	    	debt_rating        INT NULL,
    	    	[recovery]         CHAR(1) COLLATE DATABASE_DEFAULT NULL,
    	    	months             INT NULL,
    	    	probability        FLOAT NULL,
    	    	insert_update      CHAR(1) COLLATE DATABASE_DEFAULT NULL
    	    )


			IF COL_LENGTH(@grid_xml_table_name, 'months') IS NULL
			BEGIN
				SET @sql =
				'ALTER TABLE '+@grid_xml_table_name+' ADD months INT DEFAULT NULL'
				EXEC (@sql)

				SET @sql = 'update gtbl set gtbl.months = dp.months from '+@grid_xml_table_name+' gtbl inner join default_probability dp 
					on dp.effective_date = gtbl.effective_date and dp.debt_rating = gtbl.debt_rating'
				EXEC(@sql) 

			END
    	    
    	    SET @query_insert = 
    	        '    	    
    	    INSERT INTO #temp_default_probability
    	      (
    	        effective_date,
    	        debt_rating,
    	        [recovery],
    	        months,
    	        probability,
    	        insert_update
    	      )
    	    SELECT CONVERT(VARCHAR, a.effective_date, 101) [effective_date],
    	           a.debt_rating [debt_rating],
    	           ''n'' [recovery],
    	           a.months [months],
    	           a.probability [Probability],
    	           CASE 
    	                WHEN dp.id IS NULL THEN ''i''
    	                ELSE ''u''
    	           END [insert_update]
    	    FROM ' + @grid_xml_table_name +
    	        ' a
    	           LEFT JOIN default_probability dp
    	                ON  a.effective_date = dp.effective_date
    	                AND a.debt_rating = dp.debt_rating'
    	    
    	    IF @debug = 'y'
    	        PRINT(@query_insert)
    	    
    	    EXEC (@query_insert)
    	    
    	    --SELECT * FROM #temp_default_probability
    	    
    	    UPDATE dp
    	    SET    dp.effective_date = trr.effective_date,
    	           dp.debt_rating = trr.debt_rating,
    	           dp.[recovery] = 'n',
    	           dp.months = nullif(trr.months,0),
    	           dp.probability = nullif(trr.probability,0)
    	    FROM   #temp_default_probability trr
    	           INNER JOIN default_probability dp
    	                ON  trr.effective_date = dp.effective_date
    	                AND trr.debt_rating = dp.debt_rating
    	    WHERE  trr.insert_update = 'u'
    	    
    	    INSERT INTO default_probability
    	      (
    	        -- id -- this column value is auto-generated
    	        effective_date,
    	        debt_rating,
    	        [recovery],
    	        months,
    	        probability
    	      )
    	    SELECT trr.effective_date,
    	           trr.debt_rating,
    	           trr.[recovery],
    	           nullif(trr.months,0),
    	           nullif(trr.probability,0)
    	    FROM   #temp_default_probability trr
    	    WHERE  trr.insert_update = 'i'
    	    
    	    SET @delete_table = dbo.FNAProcessDeleteTableSql(@grid_xml_table_name)
    	    EXEC (@delete_table)
    	END
    	
    	IF @delete_xml IS NOT NULL
    	BEGIN
    	    CREATE TABLE #delete_xml_process_table_name
    	    (
    	    	table_name VARCHAR(200) COLLATE DATABASE_DEFAULT
    	    )
    	    INSERT INTO #delete_xml_process_table_name
    	    EXEC spa_parse_xml_file 'b',
    	         NULL,
    	         @delete_xml
    	    
    	    SELECT @delete_xml_table_name = table_name
    	    FROM   #delete_xml_process_table_name
    	    
    	    SET @query_insert = ''
    	    
    	    SET @query_insert = @query_insert +
    	        '
    	        DELETE dp
    	    FROM ' + @delete_xml_table_name +
    	        ' a
    	           LEFT JOIN default_probability dp
    	                ON  a.effective_date = dp.effective_date
    	                AND a.debt_rating = dp.debt_rating
 				'
    	    
    	    IF @debug = 'y'
    	        PRINT(@query_insert)
    	    
    	    EXEC (@query_insert)
    	    
    	    SET @delete_table = dbo.FNAProcessDeleteTableSql(@delete_xml_table_name)
    	    EXEC (@delete_table)
    	END
    	
    	EXEC spa_ErrorHandler 0,
    	     'Process Form Data',
    	     'spa_view_default_probability',
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
    	        SET @table_name = 'default_probability'
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
    	         'spa_view_default_probability',
    	         'Error',
    	         @desc,
    	         ''
    	END
    END CATCH
END
ELSE 
IF @flag = 'p'
BEGIN
	IF @show_months='1'
	BEGIN
		SET @select_sql = 
			'
			SELECT DISTINCT dp.id AS [ID],
				   dbo.FNADateFormat(dp.effective_date) AS [Effective Date],
				   sdv.code AS [Debt Rating],
				   dp.probability AS [Probability],
				   dp.months AS [Month]'+ @str_batch_table +'
			FROM   default_probability dp
			inner join static_data_value sdv on dp.debt_rating = sdv.value_id'		
	END
	ELSE
	BEGIN
		SET @select_sql = 
			'
			SELECT DISTINCT dp.id AS [ID],
				   dbo.FNADateFormat(dp.effective_date) AS [Effective Date],
				   sdv.code AS [Debt Rating],
				   dp.probability AS [Probability]'+ @str_batch_table +'
			FROM   default_probability dp
			inner join static_data_value sdv on dp.debt_rating = sdv.value_id'		
	END	
    
    IF NULLIF(@debt_rating, '') IS NOT NULL
    BEGIN
        SET @select_sql += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @debt_rating 
            + ''') a ON dp.debt_rating = a.item'
    END
    
    SET @select_sql += ' WHERE 1=1 '
    
    IF NULLIF(@as_of_date_from, '') IS NOT NULL
       AND NULLIF(@as_of_date_to, '') IS NOT NULL
    BEGIN
        SET @select_sql += 'AND dp.effective_date BETWEEN ''' + @as_of_date_from 
            + ''' AND ''' + @as_of_date_to + ''''
    END
    
    IF @debug = 'y'
        PRINT(@select_sql)
    
    EXEC (@select_sql)
END


/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board
 
IF @is_batch = 1
 
BEGIN
 
	SELECT @str_batch_table = dbo.FNABatchProcess ('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
 
	EXEC (@str_batch_table)
 
	SELECT @str_batch_table = dbo.FNABatchProcess ('c', @batch_process_id, @batch_report_param, 
				   GETDATE(), 'spa_view_default_probability', 'View Default Probability') --TODO: modify sp and report name
 
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
 