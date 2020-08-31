
IF OBJECT_ID(N'[dbo].[spa_rfx_report_dataset]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_report_dataset]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: padhikari@pioneersolutionsglobal.com
-- Create date: 2012-08-15
-- Description: Add/Update Operations for Reports
 
-- Params:
-- @flag				CHAR(1) - Operation flag
-- @process_id			VARCHAR - Operation ID
-- @report_dataset_id	INT		- Report Dataset ID
-- @source_id			INT		- Source ID
-- @report_id			INT		- Report ID
-- @alias				VARCHAR	- Alias
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_rfx_report_dataset]
	@flag				CHAR(1),
	@process_id			VARCHAR(100),
	@report_dataset_id	INT = NULL,
	@source_id			INT = NULL,
	@report_id			INT = NULL,
	@alias				VARCHAR(100) = NULL,
	@name				VARCHAR(100) = NULL,
	@tsql				VARCHAR(MAX) = NULL,
	@type_id			INT = NULL,
	@criteria			VARCHAR(5000) = NULL,
	@tsql_column_xml	VARCHAR(MAX) = NULL
AS
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
CREATE TABLE #rfx_report ( [report_id] INT)
EXEC ('INSERT INTO #rfx_report(report_id) SELECT report_id FROM ' + @rfx_report + '')

SELECT @report_id = report_id FROM #rfx_report
	
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
				EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_report_dataset', 'DB Error', 'Alias already used.', ''
				RETURN
			END
		END
		
		-- Process SQL data source type
		IF @source_id IS NULL 
		BEGIN
			DECLARE @Params NVARCHAR(500);
			SET @Params = N'@source_id INT OUTPUT';

			CREATE TABLE #sql_datasource
			(
				ErrorCode       VARCHAR(50) COLLATE DATABASE_DEFAULT,
				Module          VARCHAR(100) COLLATE DATABASE_DEFAULT,
				Area            VARCHAR(100) COLLATE DATABASE_DEFAULT,
				[Status]        VARCHAR(100) COLLATE DATABASE_DEFAULT,
				[Message]       VARCHAR(500) COLLATE DATABASE_DEFAULT,
				Recommendation  VARCHAR(500) COLLATE DATABASE_DEFAULT
			)		
			SET @sql = 'INSERT INTO data_source ([type_id],[name], report_id, alias, [tsql])
						SELECT ' + CAST(ISNULL(@type_id, '') AS VARCHAR(2)) + '
								,''' + @name + '''
								,' + CAST(@report_id AS VARCHAR(10)) + '
								,''' + ISNULL(@alias, '') + '''
								,''' + ISNULL(REPLACE(@tsql,'''', ''''''), '') + '''
								
						SET @source_id = SCOPE_IDENTITY() '
			EXEC spa_print @sql
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
			exec spa_print @sql
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
		exec spa_print @sql 
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
		
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_report_dataset', 'Success', @report_dataset_id, @source_id
	END TRY
	BEGIN CATCH
		ROLLBACK
		SELECT @error_msg = ERROR_MESSAGE()
		SET @error_no = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @error_no, 'Reporting FX', 'spa_rfx_data_source', 'DB Error', @error_msg, ''
	END CATCH
END

-- Edit Report Dataset
IF @flag = 'u'
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
							WHERE alias = ''' + @alias + ''' AND report_dataset_id <> ' + CAST(@report_dataset_id AS VARCHAR(10))
			END
			EXEC(@sql)		
			
			IF EXISTS(SELECT 1 FROM #rfx_report_analayse_unique_u) 
			BEGIN
				EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_report_dataset', 'DB Error', 'Alias already used.', ''
				RETURN
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
			EXEC spa_print @sql
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
					WHERE report_dataset_id = ' + CAST(@report_dataset_id AS VARCHAR(10)) + ' '
		EXEC spa_print @sql	
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
		
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_report_dataset', 'Success', @report_dataset_id, @source_id
			
	END TRY
	BEGIN CATCH
		ROLLBACK
		SELECT @error_msg = ERROR_MESSAGE()
		SET @error_no = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @error_no, 'Reporting FX', 'spa_rfx_data_source', 'DB Error', @error_msg, ''		 
	END CATCH
END
	
-- Get Report Datasets
IF @flag = 's'
BEGIN
    SET @sql = 'SELECT rd.report_dataset_id [Report Datasets ID],
					   rd.source_id,
					   CASE WHEN CHARINDEX(''[adiha_process].[dbo].[batch_export_'', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName]([name], ''[batch_export_'') 
							 WHEN CHARINDEX(''[adiha_process].[dbo].[report_export_'', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], ''[report_export_'')
							ELSE ds.[name]
						END
					  + '' ('' + rd.[alias] + '')'' [Name],
					   rd.[alias] [Alias]
				FROM   ' + @rfx_report_dataset + ' rd
				INNER JOIN data_source ds ON  ds.data_source_id = rd.source_id
				WHERE rd.root_dataset_id IS NULL '
				exec spa_print @sql
    EXEC (@sql)
END
	
-- Get Report Dataset
IF @flag = 'a'
BEGIN
    SET @sql = 'SELECT rd.report_datasets_id,
					   ds.[name] [Data Source Name],
					   r.[name] [Report Name],
					   rd.alias [Alias]
				FROM   ' + @rfx_report_dataset + ' rd
				INNER JOIN data_source ds ON  ds.data_source_id = rd.source_id
				INNER JOIN '+@rfx_report+' r ON  r.report_id = rd.report_id
				WHERE  rd.report_datasets_id = ' + CAST(@report_dataset_id AS VARCHAR(10)) + ''    
    EXEC (@sql)
END
	
IF @flag = 'h'
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
                       dsc.column_template [master_column_template]
                FROM   ' + @rfx_report_dataset + ' rd
                       JOIN data_source ds ON  rd.source_id = ds.data_source_id
                       JOIN data_source_column dsc ON  dsc.source_id = ds.data_source_id
                ORDER BY dsc.[alias], group_entity ASC'    
    EXEC (@sql)
END
	
IF @flag = 'r'
BEGIN
	IF @alias IS NOT NULL
	BEGIN
		CREATE TABLE #rfx_report_analayse_unique_r ( [counter_r] INT)
		DECLARE @column_count_r INT
		SET @sql = 'INSERT INTO #rfx_report_analayse_unique_r(counter_r) 
					SELECT COUNT(*) FROM   '+ @rfx_report_dataset +' WHERE  alias = '''+ @alias +''''
		EXEC(@sql)
		
		SELECT @column_count_r = counter_r FROM #rfx_report_analayse_unique_r	
		IF @column_count_r IS NOT NULL AND @column_count_r > 0
		BEGIN
			EXEC spa_ErrorHandler 1, 'Reporting FX', 'spa_rfx_report_dataset', 'DB Error', 'Alias already used.', ''
			RETURN
		END
	END
	IF @alias IS NULL
	--Automate Alias Processing first; shud open when is not about SQL datasource
	BEGIN
		CREATE TABLE #rfx_report_dataset_alias_r([alias_r] VARCHAR(100) COLLATE DATABASE_DEFAULT)
		DECLARE @source_alias_r VARCHAR(100)
		SELECT @source_alias_r = alias FROM data_source WHERE data_source_id = @source_id;
		SET @sql = 'INSERT INTO #rfx_report_dataset_alias_r (alias_r) 
					SELECT MAX(CASE WHEN ISNUMERIC(REPLACE(rd.alias, ''' + CAST(@source_alias_r AS VARCHAR(10))+''', '''')) = 1 THEN REPLACE(rd.alias, ''' + CAST(@source_alias_r AS VARCHAR(10))+''', '''') ELSE 0 END)[alias_prefix] 
					FROM ' + @rfx_report_dataset + ' rd
					WHERE rd.report_id = ' + CAST(@report_id AS VARCHAR(10)) + ' 
					AND rd.source_id = ' + CAST(@source_id AS VARCHAR(10))
		EXEC(@sql);
		SELECT @alias = alias_r FROM #rfx_report_dataset_alias_r
		IF @alias IS NULL
			SET @alias = @source_alias_r + '1'
		ELSE 
			SET @alias = @source_alias_r + CAST((CONVERT(INT,@alias)+1) AS VARCHAR(10))	
	END
	
	SET @sql = 'INSERT INTO ' + @rfx_report_dataset + '(source_id, report_id, alias, root_dataset_id)
				VALUES(
					' + CAST(@source_id AS VARCHAR(10)) + ',					
					' + CAST(@report_id AS VARCHAR(10)) + ',
					''' + @alias + ''',
					''' + CAST(@report_dataset_id AS VARCHAR(100)) + '''
				 )'
    EXEC (@sql)
    
    IF @@ERROR <> 0
        EXEC spa_ErrorHandler @@ERROR, 'Reporting FX', 'spa_rfx_report_dataset', 'DB Error', 'Fail to insert data.', ''
    ELSE
        EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_report_dataset', 'Success', 'Data successfully inserted.', ''
END

IF @flag = 'e'
BEGIN
	SET @sql = 'SELECT rd.report_dataset_id, rd.source_id, ds.[type_id], ds.[name],
					CASE WHEN ds.[type_id] = 2 THEN ds.[alias] ELSE rd.[alias] END AS [alias],
					CASE WHEN ds.[type_id] = 2 THEN ds.[tsql] ELSE '''' END AS [tsql]
				FROM '+ @rfx_report_dataset +' rd
				JOIN data_source ds ON ds.data_source_id = rd.source_id
	            WHERE rd.report_dataset_id = '+CAST(@report_dataset_id AS VARCHAR(10))
	EXEC(@sql)            
END
	
IF @flag = 'd'

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
					SELECT ' + CAST(@report_dataset_id AS VARCHAR(10)) + '
					UNION ALL
					--root dataset of its connected dataset (applicable incase of sql data source)
					SELECT rd_connected.root_dataset_id
					FROM '+ @rfx_report_dataset +' rd
					INNER JOIN data_source ds ON ds.data_source_id = rd.source_id
						AND ds.type_id = 2
					INNER JOIN '+ @rfx_report_dataset +' rd_connected ON rd_connected.source_id = ds.data_source_id
					WHERE rd.report_dataset_id = ' + CAST(@report_dataset_id AS VARCHAR(10))
		exec spa_print @sql
		EXEC (@sql)
			
		SET @sql = 'INSERT INTO #temp_dataset_tbd (dataset_id)
					SELECT ' + CAST(@report_dataset_id AS VARCHAR(10)) + '
					UNION ALL
					--its connected dataset (applicable incase of sql data source)
					SELECT rd_connected.report_dataset_id
					FROM ' + @rfx_report_dataset + ' rd
					INNER JOIN data_source ds ON ds.data_source_id = rd.source_id
						AND ds.type_id = 2
					INNER JOIN ' + @rfx_report_dataset + ' rd_connected ON rd.source_id = rd_connected.source_id 
					WHERE rd.report_dataset_id = ' + CAST(@report_dataset_id AS VARCHAR(10))
		exec spa_print @sql
		EXEC (@sql)	
			
		SET @sql = '
		IF EXISTS(SELECT 1 FROM ' + @rfx_report_dataset_relationship + ' rrdr
							 INNER JOIN #temp_dataset_tbd tdtbd ON (tdtbd.dataset_id = rrdr.dataset_id
								OR tdtbd.dataset_id = rrdr.from_dataset_id
								OR tdtbd.dataset_id = rrdr.to_dataset_id))
					BEGIN
						INSERT INTO #temp_exist_in_relationship (id) VALUES(' + CAST(@report_dataset_id AS VARCHAR(10)) + ')
					END
					IF EXISTS(SELECT 1 FROM ' + @rfx_report_dataset_paramset + ' rrdp
								INNER JOIN #temp_dataset_including_root tdt ON tdt.dataset_id = rrdp.root_dataset_id)
					BEGIN
						INSERT INTO #temp_exist_in_paramset (id) VALUES(' + CAST(@report_dataset_id AS VARCHAR(10)) + ')
					END
					IF EXISTS(SELECT 1 FROM ' + @rfx_report_page_chart + ' rrpc
							  INNER JOIN #temp_dataset_including_root tdt ON tdt.dataset_id = rrpc.root_dataset_id)
					BEGIN
						INSERT INTO #temp_exist_in_chart (id) VALUES(' + CAST(@report_dataset_id AS VARCHAR(10)) + ')
					END
					IF EXISTS(SELECT 1 FROM ' + @rfx_report_page_tablix + ' rrpt 
							  INNER JOIN #temp_dataset_including_root tdt ON tdt.dataset_id = rrpt.root_dataset_id
							  WHERE root_dataset_id = ' + CAST(@report_dataset_id AS VARCHAR(10)) + ')
					BEGIN
						INSERT INTO #temp_exist_in_tablix (id) VALUES(' + CAST(@report_dataset_id AS VARCHAR(10)) + ')
					END'
		EXEC spa_print @sql
		EXEC(@sql)
		
		IF EXISTS (SELECT 1 FROM #temp_exist_in_relationship)
		BEGIN
			EXEC spa_ErrorHandler -1,
				 'report_dataset',
				 'spa_rfx_report_dataset',
				 'Failed',
				 'Dataset is used in dataset relationship.',
				 ''
			RETURN
		END
		IF EXISTS (SELECT 1 FROM #temp_exist_in_paramset)
		BEGIN
			EXEC spa_ErrorHandler -1,
				 'report_dataset',
				 'spa_rfx_report_dataset',
				 'Failed',
				 'Dataset is used in paramset.',
				 ''
			RETURN
		END 
		IF EXISTS (SELECT 1 FROM #temp_exist_in_chart)
		BEGIN
			EXEC spa_ErrorHandler -1,
				 'report_dataset',
				 'spa_rfx_report_dataset',
				 'Failed',
				 'Dataset is used in chart.',
				 ''
			RETURN	
		END 
		IF EXISTS (SELECT 1 FROM #temp_exist_in_tablix)
		BEGIN
			EXEC spa_ErrorHandler -1,
				 'report_dataset',
				 'spa_rfx_report_dataset',
				 'Failed',
				 'Dataset is used in tablix.',
				 ''
			RETURN		
		END
			
		--capture source_id to delete (if it is sql data source)
		SET @sql = 'INSERT INTO #temp_data_source(source_id)
					SELECT source_id
					FROM ' + @rfx_report_dataset + ' rd
					WHERE rd.report_dataset_id = ' + CAST(@report_dataset_id AS VARCHAR(10))
		EXEC spa_print @sql
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
					WHERE  rd.report_dataset_id = ' + CAST(@report_dataset_id AS VARCHAR(30))
		EXEC spa_print @sql
		EXEC(@sql)
		
		--finally delete the dataset		
		IF OBJECT_ID(N'tempdb..#temp_deleted_dataset') IS NOT NULL
		DROP TABLE #temp_deleted_dataset

		create table #temp_deleted_dataset (source_id int)
		SET @sql = 'DELETE rd 
					OUTPUT DELETED.[source_id] into #temp_deleted_dataset
					FROM   ' + @rfx_report_dataset + ' rd 
					INNER JOIN #temp_dataset_tbd tdtbd ON tdtbd.dataset_id = rd.report_dataset_id'
		EXEC spa_print @sql
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
				
		EXEC spa_ErrorHandler 0, 'report_dataset', 'spa_rfx_report_dataset', 'Success', 'Data successfully deleted.', @process_id
		
		COMMIT TRAN
		
	END TRY
	BEGIN CATCH
		DECLARE @edit_error_desc VARCHAR(1000)
		DECLARE @edit_error_no INT
		SET @edit_error_no = ERROR_NUMBER()		
		SET @edit_error_desc = ERROR_MESSAGE()
		
		EXEC spa_print 'Error:', @edit_error_desc
		
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
			
		EXEC spa_ErrorHandler @edit_error_no, 'report_dataset', 'spa_rfx_report_dataset', @edit_error_desc, 'Fail to delete data.', ''
	END CATCH 				
END
