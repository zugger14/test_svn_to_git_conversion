
IF OBJECT_ID(N'[dbo].[spa_rfx_report_dataset_dhx]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_report_dataset_dhx]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
 /**
	Add/Update Operations for Reports. Created for new report manager dhx. Currently in use.

	Parameters :
	 @flag	: Operation flag
						'i' -- Insert
						'u' -- Update
						's' -- Get Report Datasets
						'a' -- Get Report Dataset
						'h' -- n/a
						'r' -- n/a
						'e' -- n/a 
						'd' -- Delete
						'f'	-- n/a
						'f1'-- n/a
						'g'	-- n/a
						'z'	-- n/a
	 @process_id		:	Operation ID
	 @report_dataset_id	:	Report Dataset ID
	 @source_id			:	Source ID
	 @report_id			:	Report ID
	 @alias				:	Alias
	 @name				:	Dataset name 
	 @tsql				:	Tsql query for dataset in case of report sql
	 @type_id			:	Datasource type id
	 @criteria			:	Filter criteria
	 @tsql_column_xml	:	Dataset column information in XML format
	 @grid_alias		:	Dataset alias from DHTMLX editable grid for connected sources.

*/

CREATE PROCEDURE [dbo].[spa_rfx_report_dataset_dhx]
	@flag				VARCHAR(50),
	@process_id			VARCHAR(100),
	@report_dataset_id	VARCHAR(5000) = NULL,
	@source_id			INT = NULL,
	@report_id			INT = NULL,
	@alias				VARCHAR(100) = NULL,
	@name				VARCHAR(100) = NULL,
	@tsql				VARCHAR(MAX) = NULL,
	@type_id			INT = NULL,
	@criteria			VARCHAR(5000) = NULL,
	@tsql_column_xml	VARCHAR(MAX) = NULL,
	--@csv_write_path		VARCHAR(2000) = NULL,
	@grid_alias			VARCHAR(2000) = NULL
AS
/*
declare @flag				CHAR(1),
	@process_id			VARCHAR(100),
	@report_dataset_id	VARCHAR(5000) = NULL,
	@source_id			INT = NULL,
	@report_id			INT = NULL,
	@alias				VARCHAR(100) = NULL,
	@name				VARCHAR(100) = NULL,
	@tsql				VARCHAR(MAX) = NULL,
	@type_id			INT = NULL,
	@criteria			VARCHAR(5000) = NULL,
	@tsql_column_xml	VARCHAR(MAX) = NULL,
	@csv_write_path		VARCHAR(2000) = NULL,
	@grid_alias			VARCHAR(2000) = NULL

	DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo
	select @flag='z', @process_id='783F1235_19DD_4067_9313_333E1F422349', @report_dataset_id='', @report_id='43937', @source_id='7250', @grid_alias=''
--*/
SET NOCOUNT ON  -- NOCOUNT is set ON since returning row count has side effects on exporting table feature
IF @process_id IS NULL
    SET @process_id = dbo.FNAGetNewID()

DECLARE @user_name   	VARCHAR(50) = dbo.FNADBUser()  
DECLARE @sql         	NVARCHAR(MAX)
DECLARE @error_no		INT
DECLARE @error_msg		VARCHAR(2000)

--Resolve Process Table Name 
DECLARE @rfx_report_dataset  VARCHAR(200) = dbo.FNAProcessTableName('report_dataset', @user_name, @process_id)
DECLARE @rfx_report          VARCHAR(200) = dbo.FNAProcessTableName('report', @user_name, @process_id)

DECLARE @rfx_report_page_chart            VARCHAR(200)
DECLARE @rfx_report_page_tablix           VARCHAR(200)
DECLARE @rfx_report_dataset_paramset      VARCHAR(200)
DECLARE @rfx_report_dataset_relationship  VARCHAR(200)
DECLARE @rfx_report_dataset_deleted       VARCHAR(200)
SET @user_name = dbo.FNADBUser()

--Resolve Process Table Name
SET @rfx_report_page_chart			= dbo.FNAProcessTableName('report_page_chart', @user_name, @process_id)
SET @rfx_report_page_tablix			= dbo.FNAProcessTableName('report_page_tablix', @user_name, @process_id)
SET @rfx_report_dataset_paramset	= dbo.FNAProcessTableName('report_dataset_paramset', @user_name, @process_id)
SET @rfx_report_dataset_relationship = dbo.FNAProcessTableName('report_dataset_relationship', @user_name, @process_id)
SET @rfx_report_dataset_deleted      = dbo.FNAProcessTableName('rfx_report_dataset_deleted', @user_name, @process_id)

--Check the existence and drop #nrfx_report
--TODO
if OBJECT_ID('tempdb..#rfx_report') is not null
	drop table #rfx_report
CREATE TABLE #rfx_report ( [report_id] INT)
EXEC ('INSERT INTO #rfx_report(report_id) SELECT report_id FROM ' + @rfx_report + '')

SELECT @report_id = report_id FROM #rfx_report

set @report_dataset_id = nullif(@report_dataset_id, '')

IF @flag IN ('i','u')
BEGIN
	IF (dbo.FNACheckUniqueDatasourceName(@name, @type_id, @source_id, @report_id) = 0)
	BEGIN
		EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_report_dataset_dhx', 'DB Error','Name already used.', ''
		RETURN
	END
END
	
-- Add New Report Dataset
IF @flag = 'i'
BEGIN
	--if alias not null; check for unique constraint
	BEGIN TRY
		BEGIN TRANSACTION
		
		
		IF @alias IS NOT NULL
		BEGIN
			CREATE TABLE #rfx_report_analayse_unique (data_exists TINYINT)
			
			IF @type_id = 2 
			BEGIN
				SET @sql = 'INSERT INTO #rfx_report_analayse_unique([data_exists]) 
							SELECT TOP(1) 1 FROM data_source 
							WHERE report_id = ' + CAST(@report_id AS VARCHAR(10)) + ' AND alias = ''' + @alias + ''''
			END
			ELSE
			BEGIN
				SET @sql = 'INSERT INTO #rfx_report_analayse_unique([data_exists]) 
							SELECT TOP(1) 1 FROM ' + @rfx_report_dataset + ' 
							WHERE alias = ''' + @alias + ''''
			END
			
			EXEC(@sql)		
			
			IF EXISTS(SELECT 1 FROM #rfx_report_analayse_unique) 
			BEGIN
				--EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_report_dataset_dhx', 'DB Error', 'Alias already used.', ''
				--rollback
				RAISERROR ('Alias already used.', 16, 1 )
				RETURN
			END
		END
		

		-- Process SQL data source type
		IF nullif(@source_id, '') IS NULL 
		BEGIN
			CREATE TABLE #sql_datasource
			(
				ErrorCode       VARCHAR(50) COLLATE DATABASE_DEFAULT,
				Module          VARCHAR(100) COLLATE DATABASE_DEFAULT,
				Area            VARCHAR(100) COLLATE DATABASE_DEFAULT,
				[Status]        VARCHAR(100) COLLATE DATABASE_DEFAULT,
				[Message]       VARCHAR(500) COLLATE DATABASE_DEFAULT,
				Recommendation  VARCHAR(500) COLLATE DATABASE_DEFAULT
			)

			DECLARE @Params NVARCHAR(500);
			SET @Params = N'@source_id INT OUTPUT';

			SET @sql = 'INSERT INTO data_source ([type_id],[name], report_id, alias, [tsql])
						SELECT ' + CAST(ISNULL(@type_id, '') AS VARCHAR(2)) + '
								,''' + @name + '''
								,' + CAST(@report_id AS VARCHAR(10)) + '
								,''' + ISNULL(@alias, '') + '''
								,''' + ISNULL(REPLACE(@tsql,'''', ''''''), '') + '''
								
						SET @source_id = SCOPE_IDENTITY()
						'
			--PRINT(@sql)
			--EXEC (@sql)
			EXECUTE sp_executesql @sql, @Params, @source_id = @source_id OUTPUT;
		END
		
		ELSE IF @alias IS NULL
		BEGIN
			
			--Automate Alias Processing first; shud open when is not about SQL datasource
			CREATE TABLE #rfx_report_dataset_alias([alias] VARCHAR(100) COLLATE DATABASE_DEFAULT)
			DECLARE @source_alias VARCHAR(100)
			SELECT @source_alias = [alias] FROM data_source WHERE data_source_id = @source_id;
			SET @sql = 'INSERT INTO #rfx_report_dataset_alias (alias) 
						SELECT MAX(CASE WHEN ISNUMERIC(REPLACE(rd.alias, ''' + @source_alias + ''', '''')) = 1 
										THEN REPLACE(rd.alias, ''' + @source_alias + ''', '''') ELSE 0 
						           END) [alias_prefix] 
						FROM ' + @rfx_report_dataset + ' rd
						WHERE rd.report_id = ' + CAST(@report_id AS VARCHAR(10)) + ' 
						AND rd.source_id = ' + CAST(@source_id AS VARCHAR(10))
			--PRINT(@sql)
			EXEC(@sql)
			SELECT @alias = [alias] FROM #rfx_report_dataset_alias
			
			IF @alias IS NULL
				SET @alias = @source_alias + '1'
			ELSE 
				SET @alias = @source_alias + CAST((CONVERT(INT, @alias) + 1) AS VARCHAR(10))
				
		END
		
		SET @sql = 'INSERT INTO ' + @rfx_report_dataset + ' (source_id, report_id, alias)
				    VALUES (
						' + CAST(@source_id AS VARCHAR(10)) + ',					
						' + CAST(@report_id AS VARCHAR(10)) + ',
						''' + @alias + '''
					)' 
		--PRINT(@sql) 
		EXEC (@sql)
		SET @report_dataset_id = IDENT_CURRENT(@rfx_report_dataset)
	  	
		
		CREATE TABLE #sql_columns_message
		(
			ErrorCode       VARCHAR(50) COLLATE DATABASE_DEFAULT,
			Module          VARCHAR(100) COLLATE DATABASE_DEFAULT,
			Area            VARCHAR(100) COLLATE DATABASE_DEFAULT,
			[Status]        VARCHAR(100) COLLATE DATABASE_DEFAULT,
			[Message]       VARCHAR(500) COLLATE DATABASE_DEFAULT,
			Recommendation  VARCHAR(500) COLLATE DATABASE_DEFAULT
		)
		
		IF @tsql_column_xml IS NOT NULL
		BEGIN
			INSERT INTO #sql_columns_message
			EXEC spa_rfx_save_data_source_column 'i', @process_id, @source_id, @tsql_column_xml	
		END	
		
		DECLARE @state_check VARCHAR(200)
		SELECT @state_check = ErrorCode FROM #sql_columns_message
		IF @state_check = 'Error'
		BEGIN
			RAISERROR ('Error Saving the Columns.', 16, 1 );
		END   
		COMMIT
		
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_report_dataset_dhx', 'Success', @report_dataset_id, @source_id
	END TRY
	BEGIN CATCH
		ROLLBACK
		SELECT @error_msg = ERROR_MESSAGE()
		SET @error_no = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @error_no, 'Reporting FX', 'spa_rfx_report_dataset_dhx', 'DB Error', @error_msg, ''
	END CATCH
END

-- Edit Report Dataset
ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
		--if alias not null; check for unique constraint
		IF @alias IS NOT NULL
		BEGIN
			CREATE TABLE #rfx_report_analayse_unique_u ([data_exists_u] TINYINT)
			
			IF @type_id = 2 
			BEGIN
				SET @sql = 'INSERT INTO #rfx_report_analayse_unique_u(data_exists_u) 
							SELECT TOP(1) 1 FROM data_source 
							WHERE report_id = ' + CAST(@report_id AS VARCHAR(10)) + ' 
								AND alias = ''' + @alias + ''' AND data_source_id <> ' + CAST(@source_id AS VARCHAR(10))
			END
			ELSE
			BEGIN
				SET @sql = 'INSERT INTO #rfx_report_analayse_unique_u(data_exists_u) 
							SELECT TOP(1) 1 FROM ' + @rfx_report_dataset + ' 
							WHERE alias = ''' + @alias + ''' AND report_dataset_id <> ' + @report_dataset_id
			END
			EXEC(@sql)		
			
			IF EXISTS(SELECT 1 FROM #rfx_report_analayse_unique_u) 
			BEGIN
				--EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_report_dataset_dhx', 'DB Error', 'Alias already used.', ''
				--rollback
				RAISERROR ('Alias already used.', 16, 1 )
				
			END
			
		END
		IF @type_id = 2
		BEGIN
			CREATE TABLE #sql_datasource1
			(
    			ErrorCode       VARCHAR(50) COLLATE DATABASE_DEFAULT,
    			Module          VARCHAR(100) COLLATE DATABASE_DEFAULT,
    			Area            VARCHAR(100) COLLATE DATABASE_DEFAULT,
    			[Status]        VARCHAR(100) COLLATE DATABASE_DEFAULT,
    			[Message]       VARCHAR(500) COLLATE DATABASE_DEFAULT,
    			Recommendation  VARCHAR(500) COLLATE DATABASE_DEFAULT
			)		
		        
			SET @sql = 'UPDATE data_source
						SET [name] = ''' + @name + ''',
							alias = ''' + ISNULL(@alias, '') + ''',
							[tsql] = ''' + ISNULL(REPLACE(@tsql, '''', ''''''), '') + '''
						WHERE [data_source_id] = ' + CAST(@source_id AS VARCHAR(200)) + ''
			--PRINT @sql
			EXEC (@sql)	   
		END
		IF @alias IS NULL
		BEGIN
			--Automate Alias Processing first; shud open when is not about SQL datasource
			CREATE TABLE #rfx_report_dataset_alias_u([alias] VARCHAR(100) COLLATE DATABASE_DEFAULT)
			DECLARE @source_alias_u VARCHAR(100)
			SELECT @source_alias_u = alias FROM data_source WHERE data_source_id = @source_id;
			SET @sql = 'INSERT INTO #rfx_report_dataset_alias_u (alias) 
						SELECT MAX(CASE WHEN ISNUMERIC(REPLACE(rd.alias, ''' + @source_alias_u +''', '''')) = 1 
										THEN REPLACE(rd.alias, ''' + @source_alias_u +''', '''') ELSE 0 
						           END)[alias_prefix] 
						FROM ' + @rfx_report_dataset + ' rd
						WHERE rd.report_id = ' + CAST(@report_id AS VARCHAR(10)) + ' 
						AND rd.source_id = ' + CAST(@source_id AS VARCHAR(10))
			EXEC(@sql)
			
			SELECT @alias = alias FROM #rfx_report_dataset_alias_u
			IF @alias IS NULL
				SET @alias = @source_alias_u + '1'
			ELSE 
				SET @alias = @source_alias_u + CAST((CONVERT(INT,@alias)+1) AS VARCHAR(10))	
		END
			
		SET @sql = 'UPDATE ' + @rfx_report_dataset + '
					SET source_id = ' + CAST(@source_id AS VARCHAR(10)) + ',
						alias = ''' + ISNULL(@alias, '') + '''
					WHERE report_dataset_id = ' + @report_dataset_id + ' '
		--PRINT @sql	
		EXEC (@sql)
		
		CREATE TABLE #sql_columns_message_u
		(
			ErrorCode       VARCHAR(50) COLLATE DATABASE_DEFAULT,
			Module          VARCHAR(100) COLLATE DATABASE_DEFAULT,
			Area            VARCHAR(100) COLLATE DATABASE_DEFAULT,
			[Status]        VARCHAR(100) COLLATE DATABASE_DEFAULT,
			[Message]       VARCHAR(500) COLLATE DATABASE_DEFAULT,
			Recommendation  VARCHAR(500) COLLATE DATABASE_DEFAULT
		)
		
		IF @tsql_column_xml IS NOT NULL
		BEGIN
			--SELECT @process_id, @source_id
			INSERT INTO #sql_columns_message_u
			EXEC spa_rfx_save_data_source_column 'u', @process_id, @source_id, @tsql_column_xml	
		END			
		
		DECLARE @state_check_u VARCHAR(200)
		SELECT @state_check_u = ErrorCode FROM #sql_columns_message_u
		IF @state_check_u = 'Error'
		BEGIN
			DECLARE @col_error_msg VARCHAR(8000)
			SELECT @col_error_msg = [Message] FROM #sql_columns_message_u
			RAISERROR (@col_error_msg, 16, 1 );
		END   
		
		COMMIT
		
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_report_dataset_dhx', 'Success', @report_dataset_id, @source_id
			
	END TRY
	BEGIN CATCH
		ROLLBACK
		SELECT @error_msg = ERROR_MESSAGE()
		SET @error_no = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @error_no, 'Reporting FX', 'spa_rfx_report_dataset_dhx', 'DB Error', @error_msg, ''		 
	END CATCH
END
	
-- Get Report Datasets
ELSE IF @flag = 's'
BEGIN
    SET @sql = 'SELECT rd.report_dataset_id [Report Datasets ID],
					   rd.source_id,
					   CASE WHEN CHARINDEX(''[adiha_process].[dbo].[batch_export_'', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName]([name], ''[batch_export_'') 
							 WHEN CHARINDEX(''[adiha_process].[dbo].[report_export_'', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], ''[report_export_'')
							ELSE ds.[name]
						END
					  + '' ('' + rd.[alias] + '')'' + case when rel.is_connected is not null then '' [C]'' else '''' end [Name],
					   rd.[alias] [Alias],
					   ds.type_id,
					   CASE ds.type_id WHEN 1 THEN ''View'' WHEN 2 THEN ''SQL'' ELSE ''Table'' END [type]
				FROM   ' + @rfx_report_dataset + ' rd
				INNER JOIN data_source ds ON  ds.data_source_id = rd.source_id
				outer apply (
					select top 1 1 [is_connected]
					from ' + @rfx_report_dataset_relationship + ' rdr
					where rdr.dataset_id = rd.report_dataset_id
				) rel
				WHERE rd.root_dataset_id IS NULL '
				----PRINT(@sql)
    EXEC (@sql)
END
-- Get Report Dataset
ELSE IF @flag = 'a'
BEGIN
    SET @sql = 'SELECT rd.report_datasets_id,
					   ds.[name] [Data Source Name],
					   r.[name] [Report Name],
					   rd.alias [Alias]
				FROM   ' + @rfx_report_dataset + ' rd
				INNER JOIN data_source ds ON  ds.data_source_id = rd.source_id
				INNER JOIN '+@rfx_report+' r ON  r.report_id = rd.report_id
				WHERE  rd.report_datasets_id = ' + @report_dataset_id + ''    
    EXEC (@sql)
END
	
ELSE IF @flag = 'h'
BEGIN
    SET @sql = 'SELECT CASE 
                            WHEN rd.root_dataset_id IS NULL THEN rd.report_dataset_id
                            WHEN rd.root_dataset_id IS NOT NULL THEN rd.root_dataset_id
                       END AS group_entity,
                       dsc.[data_source_column_id],
                       rd.[alias] + ''.'' + dsc.[alias] AS [alias],
                       rd.report_dataset_id,
                       dsc.datatype_id,
                       rd.[alias] + ''.'' + dsc.[name] AS [column_name_real],
                       dsc.[tooltip],
                       dsc.column_template [master_column_template],
					   isnull(rd.root_dataset_id, -1) root_dataset_id,
					   dsc.datatype_id
                FROM   ' + @rfx_report_dataset + ' rd
				INNER JOIN data_source ds ON  rd.source_id = ds.data_source_id
				INNER JOIN data_source_column dsc ON  dsc.source_id = ds.data_source_id
				where 1=1 ' 
				+ case when @report_dataset_id is not null 
					then ' and (rd.report_dataset_id = ' + @report_dataset_id + ' or rd.root_dataset_id = ' + @report_dataset_id + ')'
					else '' 
				  end 
				+ 
				' ORDER BY [alias] asc'    
    EXEC (@sql)
END	
ELSE IF @flag = 'r'
BEGIN
	DECLARE @idoc INT
	
	IF OBJECT_ID('tempdb..#cs_info') IS NOT NULL 
		DROP TABLE #cs_info
	EXEC sp_xml_preparedocument @idoc OUTPUT, @tsql
	
	SELECT nullif(report_dataset_id, '') report_dataset_id, source_id, nullif(alias, '') alias, report_id, root_dataset_id
	INTO #cs_info --SELECT * FROM #cs_info
	FROM OPENXML(@idoc,'/PSRecordSet/DataInfo',2) 
	WITH (
		report_dataset_id	VARCHAR(300)		'@report_dataset_id',
		source_id			VARCHAR(300)		'@source_id',
		report_id			VARCHAR(300)		'@report_id',
		alias				VARCHAR(300)		'@alias',
		root_dataset_id		VARCHAR(300)		'@root_dataset_id'
	) x
	--SELECT * FROM #cs_info
	--exec('SELECT * FROM ' + @rfx_report_dataset)
	--return
	IF EXISTS (SELECT top 1 1 FROM #cs_info WHERE alias IS NOT NULL)
	BEGIN
		IF OBJECT_ID('tempdb..#rfx_cs_alias_conflicted') IS NOT NULL 
			DROP TABLE #rfx_cs_alias_conflicted
		CREATE TABLE #rfx_cs_alias_conflicted ( source_id int, alias varchar(20) COLLATE DATABASE_DEFAULT)
		
		SET @sql = 'INSERT INTO #rfx_cs_alias_conflicted(source_id, alias) 
					SELECT rd.source_id, ci.alias 
					FROM   '+ @rfx_report_dataset +' rd
					INNER JOIN #cs_info ci ON ci.alias = rd.alias
					where ci.alias is not null and (ci.report_dataset_id is null or ci.report_dataset_id <> rd.report_dataset_id)'
					
		EXEC(@sql)
		IF exists(select top 1 1 from #rfx_cs_alias_conflicted)
		BEGIN
			declare @confilcted_alias varchar(200), @alias_err_msg varchar(500)
			SELECT @confilcted_alias = STUFF(
				(SELECT ','  + cast(m.alias AS varchar)
				from #rfx_cs_alias_conflicted m
				FOR XML PATH(''))
			, 1, 1, '')

			set @alias_err_msg = 'Alias "' + @confilcted_alias + '" already used.'

			EXEC spa_ErrorHandler 1, 'Reporting FX', 'spa_rfx_report_dataset_dhx', 'DB Error', @alias_err_msg, ''
			RETURN
		END
	END
	IF exists(SELECT top 1 1 FROM #cs_info WHERE alias IS NULL)
	--Automate Alias Processing first; shud open when is not about SQL datasource
	BEGIN
		SET @sql = 'update ci
					set ci.alias = ds.alias + cast(isnull(oa.alias_count + 1, 1) as varchar(10))
					FROM #cs_info ci
					inner join data_source ds on ds.data_source_id = ci.source_id
					outer apply (
						select top 1 replace(rd.alias, ds.alias, '''') alias_count
						from ' + @rfx_report_dataset + ' rd
						where rd.source_id = ci.source_id
							and isnumeric(replace(rd.alias, ds.alias, '''')) = 1
						order by rd.alias desc
					) oa
					where ci.alias is null

					'
		EXEC(@sql);	
	END
	--exec('select * from  ' + @rfx_report_dataset)
	SET @sql = '
	delete rd
	from ' + @rfx_report_dataset + ' rd
	where rd.root_dataset_id = ' + isnull(@report_dataset_id,'-1') + '

	INSERT INTO ' + @rfx_report_dataset + '(source_id, report_id, alias, root_dataset_id)
	select ci.source_id, ci.report_id, ci.alias, ci.root_dataset_id
	from #cs_info ci
	--where ci.report_dataset_id is null
	'
    EXEC (@sql)
	SET @sql = 'update rd
				set rd.alias = ci.alias
				from ' + @rfx_report_dataset + ' rd
				inner join #cs_info ci on ci.report_dataset_id = rd.report_dataset_id
				'
    EXEC (@sql)
    --exec('select * from  ' + @rfx_report_dataset)
	--return
    IF @@ERROR <> 0
        EXEC spa_ErrorHandler @@ERROR, 'Reporting FX', 'spa_rfx_report_dataset_dhx', 'DB Error', 'Fail to insert data.', @rfx_report_dataset
    ELSE
        EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_report_dataset_dhx', 'Success', 'Data successfully inserted.', @rfx_report_dataset
END
ELSE IF @flag = 'e'
BEGIN
	SET @sql = 'SELECT rd.report_dataset_id, rd.source_id, ds.[type_id], ds.[name],
					CASE WHEN ds.[type_id] = 2 THEN ds.[alias] ELSE rd.[alias] END AS [alias],
					CASE WHEN ds.[type_id] = 2 THEN ds.[tsql] ELSE '''' END AS [tsql]
				FROM '+ @rfx_report_dataset +' rd
				JOIN data_source ds ON ds.data_source_id = rd.source_id
	            WHERE rd.report_dataset_id = ' + @report_dataset_id
	EXEC(@sql)            
END
	
ELSE IF @flag = 'd'
BEGIN  
	BEGIN TRY
		-- delete dataset
		CREATE TABLE #temp_exist_in_relationship (id INT)
		CREATE TABLE #temp_exist_in_paramset (id INT)
		CREATE TABLE #temp_exist_in_chart (id INT)
		CREATE TABLE #temp_exist_in_tablix (id INT)
		CREATE TABLE #temp_data_source (source_id INT)
		CREATE TABLE #temp_dataset_including_root (dataset_id INT)	
		CREATE TABLE #temp_dataset_tbd (dataset_id INT)	--report_dataset to be deleted, including connected dataset incase of sql source (e.g. SQL source sdd can be used under sdh to form sdd1)
			
		SET @sql = 'INSERT INTO #temp_dataset_including_root (dataset_id)
					SELECT ' + @report_dataset_id + '
					UNION ALL
					--root dataset of its connected dataset (applicable incase of sql data source)
					SELECT rd_connected.root_dataset_id
					FROM '+ @rfx_report_dataset +' rd
					INNER JOIN data_source ds ON ds.data_source_id = rd.source_id
						AND ds.type_id = 2
					INNER JOIN '+ @rfx_report_dataset +' rd_connected ON rd_connected.source_id = ds.data_source_id
					WHERE rd.report_dataset_id = ' + @report_dataset_id
		--PRINT (@sql)
		EXEC (@sql)
			
		SET @sql = 'INSERT INTO #temp_dataset_tbd (dataset_id)
					SELECT ' + @report_dataset_id + '
					UNION ALL
					--its connected dataset (applicable incase of sql data source)
					SELECT rd_connected.report_dataset_id
					FROM ' + @rfx_report_dataset + ' rd
					INNER JOIN data_source ds ON ds.data_source_id = rd.source_id
						AND ds.type_id = 2
					INNER JOIN ' + @rfx_report_dataset + ' rd_connected ON rd.source_id = rd_connected.source_id 
					WHERE rd.report_dataset_id = ' + @report_dataset_id
		--PRINT (@sql)
		EXEC (@sql)	
			
		SET @sql = '
		IF EXISTS(SELECT 1 FROM ' + @rfx_report_dataset_relationship + ' rrdr
							 INNER JOIN #temp_dataset_tbd tdtbd ON (tdtbd.dataset_id = rrdr.dataset_id
								OR tdtbd.dataset_id = rrdr.from_dataset_id
								OR tdtbd.dataset_id = rrdr.to_dataset_id))
					BEGIN
						INSERT INTO #temp_exist_in_relationship (id) VALUES(' + @report_dataset_id + ')
					END
					IF EXISTS(SELECT 1 FROM ' + @rfx_report_dataset_paramset + ' rrdp
								INNER JOIN #temp_dataset_including_root tdt ON tdt.dataset_id = rrdp.root_dataset_id)
					BEGIN
						INSERT INTO #temp_exist_in_paramset (id) VALUES(' + @report_dataset_id + ')
					END
					IF EXISTS(SELECT 1 FROM ' + @rfx_report_page_chart + ' rrpc
							  INNER JOIN #temp_dataset_including_root tdt ON tdt.dataset_id = rrpc.root_dataset_id)
					BEGIN
						INSERT INTO #temp_exist_in_chart (id) VALUES(' + @report_dataset_id + ')
					END
					IF EXISTS(SELECT 1 FROM ' + @rfx_report_page_tablix + ' rrpt 
							  INNER JOIN #temp_dataset_including_root tdt ON tdt.dataset_id = rrpt.root_dataset_id
							  WHERE root_dataset_id = ' + @report_dataset_id + ')
					BEGIN
						INSERT INTO #temp_exist_in_tablix (id) VALUES(' + @report_dataset_id + ')
					END'
		--PRINT @sql
		EXEC(@sql)
		
		IF EXISTS (SELECT 1 FROM #temp_exist_in_relationship)
		BEGIN
			EXEC spa_ErrorHandler -1,
				 'report_dataset',
				 'spa_rfx_report_dataset_dhx',
				 'Failed',
				 'Dataset is used in dataset relationship.',
				 ''
			RETURN
		END
		IF EXISTS (SELECT 1 FROM #temp_exist_in_paramset)
		BEGIN
			EXEC spa_ErrorHandler -1,
				 'report_dataset',
				 'spa_rfx_report_dataset_dhx',
				 'Failed',
				 'Dataset is used in paramset.',
				 ''
			RETURN
		END 
		IF EXISTS (SELECT 1 FROM #temp_exist_in_chart)
		BEGIN
			EXEC spa_ErrorHandler -1,
				 'report_dataset',
				 'spa_rfx_report_dataset_dhx',
				 'Failed',
				 'Dataset is used in chart.',
				 ''
			RETURN	
		END 
		IF EXISTS (SELECT 1 FROM #temp_exist_in_tablix)
		BEGIN
			EXEC spa_ErrorHandler -1,
				 'report_dataset',
				 'spa_rfx_report_dataset_dhx',
				 'Failed',
				 'Dataset is used in tablix.',
				 ''
			RETURN		
		END
			
		--capture source_id to delete (if it is sql data source)
		SET @sql = 'INSERT INTO #temp_data_source(source_id)
					SELECT source_id
					FROM ' + @rfx_report_dataset + ' rd
					WHERE rd.report_dataset_id = ' + @report_dataset_id
		--PRINT @sql
		EXEC(@sql)
			
		BEGIN TRAN

		--delete child dataset
		IF OBJECT_ID(N'tempdb..#temp_deleted_dataset_child') IS NOT NULL
		DROP TABLE #temp_deleted_dataset_child
		
		create table #temp_deleted_dataset_child (source_id int)
		

		SET @sql = 'DELETE rd_child 
					OUTPUT DELETED.[source_id] into #temp_deleted_dataset_child
					FROM ' + @rfx_report_dataset + ' rd
					INNER JOIN ' + @rfx_report_dataset + ' rd_child ON rd.report_dataset_id = rd_child.root_dataset_id 
					WHERE  rd.report_dataset_id = ' + @report_dataset_id
		--PRINT @sql
		EXEC(@sql)
		
		--finally delete the dataset		
		IF OBJECT_ID(N'tempdb..#temp_deleted_dataset') IS NOT NULL
		DROP TABLE #temp_deleted_dataset

		create table #temp_deleted_dataset (source_id int)
		SET @sql = 'DELETE rd 
					OUTPUT DELETED.[source_id] into #temp_deleted_dataset
					FROM   ' + @rfx_report_dataset + ' rd 
					INNER JOIN #temp_dataset_tbd tdtbd ON tdtbd.dataset_id = rd.report_dataset_id'
		--PRINT @sql
		EXEC(@sql)	
		
		--insert into table for final save in spa_rfx_save			
		set @sql = 'INSERT INTO ' + @rfx_report_dataset_deleted + '(source_id)
					select * 
					from (
						select * from #temp_deleted_dataset
						union 
						select * from #temp_deleted_dataset
					)a '

		EXEC spa_print @sql
		exec(@sql)
				
		EXEC spa_ErrorHandler 0, 'report_dataset', 'spa_rfx_report_dataset_dhx', 'Success', 'Data successfully deleted.', @process_id
		
		COMMIT TRAN
		
	END TRY
	BEGIN CATCH
		DECLARE @edit_error_desc VARCHAR(1000)
		DECLARE @edit_error_no INT
		SET @edit_error_no = ERROR_NUMBER()		
		SET @edit_error_desc = ERROR_MESSAGE()
		
		--PRINT 'Error:' + @edit_error_desc
		
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
			
		EXEC spa_ErrorHandler @edit_error_no, 'report_dataset', 'spa_rfx_report_dataset_dhx', @edit_error_desc, 'Fail to delete data.', ''
	END CATCH 				
END

ELSE if @flag IN( 'f', 'f1')
begin
	
	DECLARE @tab_process_table VARCHAR(300) = dbo.FNAProcessTableName('tab_process_table', @user_name, @process_id)
	DECLARE @report_process_table VARCHAR(300) = dbo.FNAProcessTableName('report_process_table', @user_name, @process_id)
	DECLARE @report_grid_name_process_table VARCHAR(300) = dbo.FNAProcessTableName('report_grid_name_process_table', @user_name, @process_id)
	DECLARE @report_dataset_csv_cols VARCHAR(500) = dbo.FNAProcessTableName('report_dataset_csv_cols', @user_name, @process_id)
	DECLARE @rfx_secondary_filters_info VARCHAR(500) = dbo.FNAProcessTableName('rfx_secondary_filters_info', @user_name, @process_id)
	
	
	if OBJECT_ID(@tab_process_table) is not null
	exec('drop table ' + @tab_process_table)
	SET @sql = '
			SELECT 
				application_group_id,ISNULL(field_layout,''1C'') field_layout,application_grid_id,ISNULL(sequence,1)  sequence, ''n'' is_udf_tab, REPLACE(ag.group_name, ''"'', ''\"'') group_name, ag.default_flag, ''n'' is_new_tab
			INTO '+@tab_process_table+'
			FROM	application_ui_template_group ag 
					INNER JOIN application_ui_template at on at.application_ui_template_id = ag.application_ui_template_id
			WHERE 
				application_function_id = 10202200 AND at.template_name = ''report template''
			ORDER BY ag.sequence asc '
	EXEC(@sql)

	declare @application_group_id int
	SELECT @application_group_id = application_group_id
	FROM application_ui_template_group ag 
	INNER JOIN application_ui_template at on at.application_ui_template_id = ag.application_ui_template_id
	WHERE application_function_id = 10202200 AND at.template_name = 'report template'

	-- Default size
	DECLARE @default_field_size INT
			, @default_column_num_per_row INT
			, @default_offsetleft INT
			, @default_fieldset_offsettop INT
			, @default_filter_field_size INT
			, @default_fieldset_width INT =1000
	
	-- Set Default Values
	SELECT @default_field_size =  var_value 
	FROM adiha_default_codes_values 
	WHERE default_code_id = 86 AND instance_no = 1
		AND seq_no = 1 --form 

	SELECT @default_column_num_per_row =  var_value FROM adiha_default_codes_values WHERE default_code_id = 86 AND seq_no = 4 AND instance_no = 1
	SELECT @default_offsetleft =  var_value FROM adiha_default_codes_values WHERE default_code_id = 86 AND seq_no = 3 AND instance_no = 1
	SELECT @default_fieldset_offsettop =  var_value FROM adiha_default_codes_values WHERE default_code_id = 86 AND seq_no = 5 AND instance_no = 1
	SELECT @default_fieldset_width =  var_value FROM adiha_default_codes_values WHERE default_code_id = 86 AND seq_no = 8 AND instance_no = 1


	
	IF OBJECT_ID('tempdb..#report_criteria_process_table_columns') IS NOT NULL
		DROP TABLE #report_criteria_process_table_columns
	
	CREATE TABLE #report_criteria_process_table_columns
	(
		application_field_id varchar(200) COLLATE DATABASE_DEFAULT,
		id INT,
		[type] varchar(200) COLLATE DATABASE_DEFAULT,
		name varchar(200) COLLATE DATABASE_DEFAULT,
		label varchar(200) COLLATE DATABASE_DEFAULT,
		[validate] varchar(200) COLLATE DATABASE_DEFAULT,
		[value] VARCHAR(200) COLLATE DATABASE_DEFAULT,
		default_format varchar(200) COLLATE DATABASE_DEFAULT,
		is_hidden varchar(200) COLLATE DATABASE_DEFAULT,
		field_size varchar(200) COLLATE DATABASE_DEFAULT,
		field_id varchar(200) COLLATE DATABASE_DEFAULT,
		header_detail varchar(200) COLLATE DATABASE_DEFAULT,
		system_required varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 'n',
		[disabled] varchar(200) COLLATE DATABASE_DEFAULT,
		has_round_option varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 'n',
		update_required varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 'n',
		data_flag varchar(200) COLLATE DATABASE_DEFAULT,
		insert_required varchar(200) COLLATE DATABASE_DEFAULT,
		tab_name varchar(200) COLLATE DATABASE_DEFAULT,
		tab_description varchar(200) COLLATE DATABASE_DEFAULT,
		tab_active_flag varchar(200) COLLATE DATABASE_DEFAULT,
		tab_sequence varchar(200) COLLATE DATABASE_DEFAULT,
		sql_string varchar(max) COLLATE DATABASE_DEFAULT,
		fieldset_name varchar(200) COLLATE DATABASE_DEFAULT,
		className varchar(200) COLLATE DATABASE_DEFAULT,
		fieldset_is_disable varchar(200) COLLATE DATABASE_DEFAULT,
		fieldset_is_hidden varchar(200) COLLATE DATABASE_DEFAULT,
		inputLeft varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 0,
		inputTop varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 0,
		fieldset_label varchar(200) COLLATE DATABASE_DEFAULT,
		offsetLeft varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 0,
		offsetTop varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 0,
		fieldset_position varchar(200) COLLATE DATABASE_DEFAULT,
		fieldset_width varchar(200) COLLATE DATABASE_DEFAULT,
		fieldset_id varchar(200) COLLATE DATABASE_DEFAULT,
		fieldset_seq varchar(200) COLLATE DATABASE_DEFAULT,
		blank_option varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 'y',
		inputHeight varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 200,
		group_name varchar(200) COLLATE DATABASE_DEFAULT,
		group_id varchar(200) COLLATE DATABASE_DEFAULT,
		application_function_id varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 10202200,
		template_name varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 'report criteria',
		position varchar(200) COLLATE DATABASE_DEFAULT,
		num_column varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 5,
		field_hidden varchar(200) COLLATE DATABASE_DEFAULT,
		field_seq VARCHAR(200) COLLATE DATABASE_DEFAULT,
		text_row_num INT, 
		validation_message VARCHAR(200) COLLATE DATABASE_DEFAULT, 
		hyperlink_function VARCHAR(200) COLLATE DATABASE_DEFAULT,
		char_length INT,
		udf_template_id VARCHAR(10) COLLATE DATABASE_DEFAULT,
		dependent_field varchar(200) COLLATE DATABASE_DEFAULT,
		dependent_query varchar(200) COLLATE DATABASE_DEFAULT,
		[sequence]		int,
		original_label VARCHAR(128) COLLATE DATABASE_DEFAULT,
		open_ui_function_id INT
	)

	set @sql = '

	if OBJECT_ID(''tempdb..##tmp_all_cols'') is not null
	drop table ##tmp_all_cols
	SELECT 
	--case when rd.root_dataset_id is null then ''rfx_dataset_csv_'' + cast(rd.report_dataset_id as varchar(10)) + ''_' + @process_id + '.csv'' else null end csv_file_name, 
	case when rd.root_dataset_id is null then 
		case when ds.type_id in (1,3) and rel.is_connected is null then '''' else r.name + ''^'' end 
		+ ds.name + ''.csv'' 
		else null 
	end csv_file_name
	
	, rd.report_dataset_id,rd.root_dataset_id,ds.name [data_source_name],dsc.* 
	into ##tmp_all_cols
	from ' + @rfx_report_dataset + ' rd
	inner join data_source ds on ds.data_source_id = rd.source_id
	inner join data_source_column dsc on dsc.source_id = ds.data_source_id
	inner join ' + @rfx_report + ' r on r.report_id = rd.report_id
	outer apply (
		select top 1 1 [is_connected]
		from ' + @rfx_report_dataset_relationship + ' rdr
		where rdr.dataset_id = rd.report_dataset_id
	) rel
	where 1=1 and dsc.required_filter is not null and (rd.report_dataset_id in (' + @report_dataset_id + ') or rd.root_dataset_id in (' + @report_dataset_id + '))

	if OBJECT_ID(''tempdb..##tmp_unique_cols'') is not null
		drop table ##tmp_unique_cols
	select max(tac.data_source_column_id) data_source_column_id, tac.name, tac.widget_id, tac.alias, tac.param_data_source
		, tac.required_filter [required_filter]
	into ##tmp_unique_cols --select * from ##tmp_unique_cols
	from ##tmp_all_cols tac
	group by tac.name, tac.widget_id, tac.alias, tac.param_data_source, tac.required_filter
	order by tac.name

	--dump all cols giving rank with partition of alias and name
	if object_id(''tempdb..#tmp_ranked_cols'') is not null
		drop table #tmp_ranked_cols
	select * 
	into #tmp_ranked_cols
	from (
		SELECT tuc.data_source_column_id [application_field_id]
		
			, row_number() over(partition by tuc.alias
				order by 
				case tuc.widget_id 
					when 7 then 1 
					when 2 then 2 
					when 6 then 3 
				else 4 end) drank_ref_alias
			, row_number() over(partition by tuc.name
				order by 
				case tuc.widget_id 
					when 7 then 1 
					when 2 then 2 
					when 6 then 3 
				else 4 end) drank_ref_name
			, CASE
					WHEN tuc.widget_id = 3 THEN ''book_structure'' ELSE tuc.name
			  END [field_id]
			, CASE
					WHEN tuc.widget_id = 3 THEN ''book_structure'' ELSE tuc.name
			  END [name]
			, CASE
					WHEN tuc.widget_id = 3 THEN ''Book Structure'' ELSE tuc.alias
			  END [label]
			, '''' [value]
			, tuc.param_data_source [sql_string]
			, '''' [validate]
			,CASE 
				WHEN tuc.widget_id = 6 THEN ''calendar''
				WHEN tuc.widget_id IN (2, 9) THEN ''combo''
				WHEN tuc.widget_id = 1 THEN ''input''
				WHEN tuc.widget_id = 7 THEN ''browser''
				WHEN tuc.widget_id in(3) THEN ''browser''
			END [type],
			''n'' [is_hidden],
			250 [field_size],
			''h'' [header_detail],
			iif(isnull(tuc.required_filter+0, -1) = 1, ''y'', ''n'') [insert_required],
			''n'' [disabled],
			''n'' [data_flag],
			''tab1'' [tab_name],
			''y'' tab_active_flag,
			''1'' tab_sequence,
			''fieldset'' [fieldset_label],
			null [fieldset_position],
			''General'' [group_name],
			' + cast(@application_group_id as varchar(10)) + ' [group_id],
			''label-top'' [position],
			''n'' [field_hidden],
			'''' [validation_message]
		from ##tmp_unique_cols tuc
	) a

	--dump only secondary cols that are excluded being duplicate cols
	if object_id(''tempdb..#tmp_secondary_cols'') is not null
		drop table #tmp_secondary_cols
	select trc.field_id [col_name]
		, trc.label
		, ca_org_col.field_id [filter_col]
		, null [filter_value]
	into #tmp_secondary_cols
	from #tmp_ranked_cols trc
	cross apply (
		select trc1.field_id
		from #tmp_ranked_cols trc1
		where trc1.label = trc.label and trc1.field_id <> trc.field_id
	) ca_org_col
	where trc.drank_ref_alias > 1 and trc.drank_ref_name = 1
	
	if object_id(''' + @rfx_secondary_filters_info + ''') is not null
		drop table ' + @rfx_secondary_filters_info + '

	select * into ' + @rfx_secondary_filters_info + ' 
	from #tmp_secondary_cols

	INSERT INTO #report_criteria_process_table_columns (
		application_field_id,
		id,
		field_id,
		[name],
		label,
		VALUE,
		sql_string,
		validate,
		[type],
		is_hidden,
		field_size,
		header_detail,
		insert_required,
		[disabled],
		data_flag,
		tab_name,
		tab_active_flag,
		tab_sequence,
		fieldset_label,
		fieldset_position,
		group_name,
		group_id,
		position,
		field_hidden,
		validation_message,
		udf_template_id,
		dependent_field,
		dependent_query,
		[sequence],
		original_label
	)
	select trc.application_field_id, row_number() over(order by trc.label) [id], trc.field_id, trc.name, REPLACE(trc.label, ''"'', ''\"'')
		, REPLACE(trc.value, ''"'', ''\"''), trc.sql_string, trc.validate, trc.type, trc.is_hidden
		, trc.field_size, trc.header_detail
		, isnull(ca_ins_req.insert_required, trc.insert_required) [insert_required]
		, trc.disabled, trc.data_flag
		, trc.tab_name, trc.tab_active_flag, trc.tab_sequence, trc.fieldset_label, trc.fieldset_position
		, trc.group_name, trc.group_id, trc.position, trc.field_hidden
		, case when coalesce(ca_ins_req.insert_required, trc.insert_required, ''n'') = ''y'' then ''Required Field.'' else '''' end [validation_message],'''',NULL,NULL,NULL,NULL
	from #tmp_ranked_cols trc
	outer apply (
		select top 1 trc1.insert_required
		from #tmp_ranked_cols trc1
		where trc1.label = trc.label 
			and trc1.insert_required = ''y''
	) ca_ins_req
	where trc.drank_ref_alias = 1 and trc.drank_ref_name = 1
	
	--select * from #tmp_ranked_cols order by label
	--select * from #tmp_secondary_cols order by label
	'
	exec spa_print @sql
	exec(@sql)

	--select * from #report_criteria_process_table_columns order by label
	--return

	/** STORE CSV FILE INFO START **/
	if OBJECT_ID(@report_dataset_csv_cols) is not null
	exec('drop table ' + @report_dataset_csv_cols)
	
	set @sql = '
	SELECT 
	case when rd.root_dataset_id is null then 
		case when ds.type_id in (1,3) and rel.is_connected is null then '''' else r.name + ''^'' end 
		+ ds.name + ''.csv'' 
		else null 
	end csv_file_name
	, rd.report_dataset_id, ds.name [data_source_name], ds.data_source_id [source_id], isnull(rel.is_connected, 0) [is_connected]
	into ' + @report_dataset_csv_cols + ' 
	from ' + @rfx_report_dataset + ' rd
	inner join data_source ds on ds.data_source_id = rd.source_id
	inner join ' + @rfx_report + ' r on r.report_id = rd.report_id
	outer apply (
		select top 1 1 [is_connected]
		from ' + @rfx_report_dataset_relationship + ' rdr 
		where rdr.dataset_id = rd.report_dataset_id
	) rel
	where 1=1 and rd.root_dataset_id is null and rd.report_dataset_id in (' + @report_dataset_id + ')'
	exec spa_print @sql
	exec(@sql)

	/** STORE CSV FILE INFO END **/

	declare @max_id int
	SELECT @max_id = isnull(MAX(CAST(id AS INT)),0)
	FROM #report_criteria_process_table_columns

	INSERT INTO #report_criteria_process_table_columns
	VALUES (NULL,@max_id+1,'settings',NULL,NULL,NULL,NULL,NULL,'n',250,NULL,NULL,NULL,'n','n','n','n','n','Report Criteria',NULL,'n',2,NULL,NULL,NULL,NULL,NULL,0,0,'fieldset',0,0,NULL,NULL,NULL,NULL,'y',200,'General',@application_group_id,10202200,'report template','label-top',5,'n',0, NULL, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL, NULL)

	if not exists(select top 1 1 from ##tmp_unique_cols)
	begin
		INSERT INTO #report_criteria_process_table_columns
		VALUES (NULL,@max_id+2,'label','no_filters','No filters',NULL,NULL,'input','n',250,NULL,NULL,NULL,'n','n','n','n','n','Report Criteria',NULL,'n',2,NULL,NULL,NULL,NULL,NULL,0,0,'fieldset',0,0,NULL,NULL,NULL,NULL,'y',200,'General',@application_group_id,10202200,'report template','label-top',5,'n',0, NULL, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL, NULL)
	end
	
	
	if OBJECT_ID(@report_process_table) is not null
	exec('drop table ' + @report_process_table)
	EXEC ('select * into ' + @report_process_table + ' FROM #report_criteria_process_table_columns')

	IF OBJECT_ID('tempdb..#tmp_browser') IS NOT NULL
		DROP TABLE #tmp_browser

	CREATE TABLE #tmp_browser
	(
		farrms_field_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
		grid_name VARCHAR(100) COLLATE DATABASE_DEFAULT
	)

	INSERT INTO #tmp_browser (farrms_field_id, grid_name)
	SELECT CASE WHEN tuc.widget_id = 5 THEN 'book_structure' ELSE tuc.name END column_name, tuc.param_data_source
	--select *
	FROM ##tmp_unique_cols tuc
	WHERE NULLIF(tuc.param_data_source, '') IS NOT NULL AND tuc.widget_id IN (5,7)
	
	if OBJECT_ID(@report_grid_name_process_table) is not null
	exec('drop table ' + @report_grid_name_process_table)
	EXEC ('SELECT * INTO ' + @report_grid_name_process_table + ' FROM #tmp_browser')
 --select * from #tmp_browser
	IF ((SELECT COUNT(*) FROM #tmp_browser) = 0) 
		SET @report_grid_name_process_table = NULL
	--exec('select * from ' + @report_process_table)
	--select @tab_process_table, @report_process_table, @report_grid_name_process_table
	--return

	IF @flag = 'f'
	BEGIN
	EXEC spa_convert_to_form_json @tab_process_table, @report_process_table, NULL, @report_grid_name_process_table, NUll, @is_report = 'c'
	END
end
else if @flag = 'g'
begin
	DECLARE @report_dataset_csv_file_info VARCHAR(500) = dbo.FNAProcessTableName('report_dataset_csv_file_info', @user_name, @process_id)
	
	set @sql = '
	select	rd.report_dataset_id, 
			case when rd.root_dataset_id is null then 
				case when ds.type_id in (1,3) and rel.is_connected is null then '''' else r.name + ''^'' end 
				+ ds.name + ''.csv'' 
				else null 
			end csv_file_name,
			dbo.FNAFileExists(cs.document_path + ''\report_manager_views\'' + 
				case when rd.root_dataset_id is null then 
					case when ds.type_id in (1,3) and rel.is_connected is null then '''' else r.name + ''^'' end 
					+ ds.name + ''.csv'' 
					else null 
				end) file_exists
	from ' + @rfx_report_dataset + ' rd
	inner join data_source ds on ds.data_source_id = rd.source_id
	inner join ' + @rfx_report + ' r on r.report_id = rd.report_id
	outer apply (
		select top 1 1 [is_connected]
		from ' + @rfx_report_dataset_relationship + ' rdr
		where rdr.dataset_id = rd.report_dataset_id
	) rel
	cross join connection_string cs
	where rd.root_dataset_id is null
	'
	exec(@sql)
	
end
else if @flag = 'z' --populate alias of connected sources on dataset
begin

	--CREATE TABLE #rfx_report_analayse_unique (data_exists TINYINT)
			
	--IF @type_id = 2 
	--BEGIN
	--	SET @sql = 'INSERT INTO #rfx_report_analayse_unique([data_exists]) 
	--				SELECT TOP(1) 1 FROM data_source 
	--				WHERE report_id = ' + CAST(@report_id AS VARCHAR(10)) + ' AND alias = ''' + @alias + ''''
	--END
	--ELSE
	--BEGIN
	--	SET @sql = 'INSERT INTO #rfx_report_analayse_unique([data_exists]) 
	--				SELECT TOP(1) 1 FROM ' + @rfx_report_dataset + ' 
	--				WHERE alias = ''' + @alias + ''''
	--END
			
	--EXEC(@sql)		
			
	--IF EXISTS(SELECT 1 FROM #rfx_report_analayse_unique) 
	--BEGIN
	--	EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_report_dataset_dhx', 'DB Error', 'Alias already used.', ''
	--	RETURN
	--END

	

	--Automate Alias Processing first; shud open when is not about SQL datasource
	DECLARE @source_alias_c VARCHAR(100)
	SELECT @source_alias_c = [alias] FROM data_source WHERE data_source_id = @source_id;

	declare @t_sql nvarchar(max)
	declare @suffix1 char(2)
	declare @suffix2 char(2)

	--if alias for that dataset_id and source_id exists return the saved alias.
	declare @saved_alias varchar(100)
	if @report_dataset_id is not null
	begin
		set @t_sql = '
		select @saved_alias = rd.alias
		from ' + @rfx_report_dataset + ' rd
		where rd.report_dataset_id = ' + @report_dataset_id + ' and rd.source_id = ' + cast(@source_id as varchar(10)) + '
		order by rd.alias desc
		'
	
		EXECUTE sp_executesql @t_sql, N'@saved_alias CHAR(100) OUTPUT', @saved_alias = @saved_alias OUTPUT
	end
	
		
	set @t_sql = '
	select top 1 @suffix1 = replace(rd.alias, ''' + @source_alias_c + ''', '''')
	from ' + @rfx_report_dataset + ' rd
	where isnumeric(replace(rd.alias, ''' + @source_alias_c + ''', '''')) = 1
	order by rd.alias desc
	'
	EXECUTE sp_executesql @t_sql, N'@suffix1 CHAR(2) OUTPUT', @suffix1 = @suffix1 OUTPUT

	
	set @t_sql = '
	select top 1 @suffix2 = replace(scsv.item, ''' + @source_alias_c + ''', '''')
	from dbo.SplitCommaSeperatedValues(''' + @grid_alias + ''') scsv
	where isnumeric(replace(scsv.item, ''' + @source_alias_c + ''', '''')) = 1
	order by scsv.item desc
	'
	EXECUTE sp_executesql @t_sql, N'@suffix2 CHAR(2) OUTPUT', @suffix2 = @suffix2 OUTPUT

	select isnull(@saved_alias, 
		@source_alias_c + coalesce(cast(iif(isnull(@suffix1,0) > isnull(@suffix2,0), @suffix1, @suffix2) + 1 as char(2)), '1') 
		) [populated_alias]
		
end
