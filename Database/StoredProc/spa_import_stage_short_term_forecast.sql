
IF OBJECT_ID(N'spa_import_stage_short_term_forecast', N'P') IS NOT NULL
DROP PROC [dbo].[spa_import_stage_short_term_forecast]
GO 


CREATE PROC [dbo].[spa_import_stage_short_term_forecast]
	@flag CHAR(1),	-- c: create tables, p: process
	@process_id varchar(100),  
	@user_login_id varchar(50) = NULL,
	@filename VARCHAR(128) = NULL,
	@input_folder VARCHAR(25) = NULL,
	@error_code VARCHAR(2) = '0',  /* @error_code  0 - no error, 1 - Working folder Empty, 2 - Invalid file format error (occurs when DFT component fails)	*/
	@stage_st_header_log_id VARCHAR(20) = NULL
AS 


DECLARE @sql VARCHAR(8000)
DECLARE @stage_st_header_log VARCHAR(128), @stage_st_forecast_hour VARCHAR(128), @stage_st_forecast_mins VARCHAR(128) 
DECLARE @as_of_date VARCHAR(30)
DECLARE @elapsed_sec INT, @elapse_sec_text VARCHAR(150)
DECLARE @error_msg VARCHAR(300)

SELECT @user_login_id = ISNULL(@user_login_id,dbo.FNADBUser())
SELECT @stage_st_header_log = dbo.FNAProcessTableName('stage_st_header_log', @user_login_id, @process_id)
SELECT @stage_st_forecast_hour = dbo.FNAProcessTableName('stage_st_forecast_hour', @user_login_id, @process_id)
SELECT @stage_st_forecast_mins = dbo.FNAProcessTableName('stage_st_forecast_mins', @user_login_id, @process_id)

SET @as_of_date = GETDATE()


IF @flag = 'c'
BEGIN
	SET @sql = 'IF OBJECT_ID(''' + @stage_st_header_log + ''') IS NOT NULL
		DROP TABLE ' + @stage_st_header_log 
	EXEC(@sql)

	SET @sql = 'IF OBJECT_ID(''' + @stage_st_forecast_hour + ''') IS NOT NULL
		DROP TABLE ' + @stage_st_forecast_hour 
	EXEC(@sql)

	SET @sql = 'IF OBJECT_ID(''' + @stage_st_forecast_mins + ''') IS NOT NULL
		DROP TABLE ' + @stage_st_forecast_mins 
	EXEC(@sql)
	
	SET @sql = 'CREATE TABLE ' + @stage_st_header_log + '(
		[stage_st_header_log_id] [INT] IDENTITY(1,1) NOT NULL,
		[filename] [VARCHAR] (100) NULL,
		[input_folder] [VARCHAR] (100) NULL,
		[error] [VARCHAR] (500) NULL,
		[error_code] [VARCHAR] (10) NULL,		
		[create_user] VARCHAR(128) NULL,
		[create_ts] DATETIME NULL
		)'
	EXEC(@sql)

	SET @sql = '
	CREATE TABLE ' + @stage_st_forecast_hour + '
	 (
		[stage_st_forecast_hour_id] [int] IDENTITY(1,1) NOT NULL,
		[stage_st_header_log_id] [INT] NOT NULL,
		[st_forecast_group_name] [VARCHAR](128) NOT NULL, [term_start] VARCHAR(10), [Hr] INT, [value] VARCHAR(64)
	 )'
	 
	EXEC(@sql)
	
	SET @sql = '
	CREATE TABLE ' + @stage_st_forecast_mins + '
	 (
		[stage_st_forecast_hour_id] [int] IDENTITY(1,1) NOT NULL,
		[stage_st_header_log_id] [INT] NOT NULL,
		[st_forecast_group_name] [VARCHAR](128) NOT NULL, [term_start] VARCHAR(10), [Hr] INT, [value] VARCHAR(64)
	 )'
	 
	EXEC(@sql)
	
		
END

ELSE IF @flag = 'p'
BEGIN
	DECLARE @type CHAR(2)
	DECLARE @url_desc VARCHAR(500)  
	DECLARE @url VARCHAR(250)
	DECLARE @desc VARCHAR(250) = ''
	DECLARE @caught BIT = 0

	CREATE TABLE #error_files(filename VARCHAR(100) COLLATE DATABASE_DEFAULT, input_folder VARCHAR(100) COLLATE DATABASE_DEFAULT)


	IF @error_code = 1  -- empty folder error
	BEGIN
		SET @type = 'e'
		-- disabled to prevent msg flood due to high frequency execution
		--EXEC spa_source_system_data_import_status_detail 'i', @process_id, '', 'Data Error', 'Data Folder Empty', 'Data Folder Empty', @user_login_id, 1 , 'Import Data'
	END
	ELSE
	BEGIN
		--BEGIN TRY
		DECLARE @each VARCHAR(255)
		CREATE TABLE #ignored_st_data([type] VARCHAR(10) COLLATE DATABASE_DEFAULT, [filename] VARCHAR(128) COLLATE DATABASE_DEFAULT, [st_forecast_group_name] VARCHAR(128) COLLATE DATABASE_DEFAULT, prior_data_count INT)

		CREATE TABLE #error_st_group(stage_st_header_log_id INT, st_forecast_group_name VARCHAR(128) COLLATE DATABASE_DEFAULT, error_type INT)
		/*
		* error_type 1: missing/invalid st forecast grp name
		* 2: invalid value, non numeric
		* 
		*/

		DECLARE c CURSOR FOR
			SELECT Item FROM dbo.SplitCommaSeperatedValues(@stage_st_forecast_hour + ',' + @stage_st_forecast_mins)
		OPEN c
		FETCH NEXT FROM c INTO @each
		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			EXEC('DELETE t FROM ' + @each + ' t 
			  INNER JOIN ' + @stage_st_header_log + ' h ON h.stage_st_header_log_id = t.stage_st_header_log_id
			  WHERE h.error_Code <> ''0''  ')	
			
				--issue in sql 2008 R2, where CR (10) and LF (13) characters exists in last row of data
				EXEC('UPDATE t SET t.value = REPLACE(REPLACE(t.value, CHAR(13), ''''), CHAR(10), '''') FROM ' + @each + ' t')

				---- Error handling: incorrect granularity in power and gas (wrong files in power and gas respectively)
				--EXEC('INSERT INTO #error_st_group(stage_st_header_log_id, st_forecast_group_name, error_type)
				--SELECT DISTINCT h.stage_st_header_log_id, t.st_forecast_group_name, 3 FROM ' + @stage_st_header_log + ' h
				--INNER JOIN  ' + @each + ' t ON t.stage_st_header_log_id = h.stage_st_header_log_id
				--WHERE CHARINDEX(''stage_st_forecast_hour'', ''' + @each + ''') <> 0 AND t.Hr > 25 ' )
				  
				-- Error handling: Missing/undefined ST group name
				EXEC('INSERT INTO #error_st_group(stage_st_header_log_id, st_forecast_group_name, error_type)
				SELECT DISTINCT h.stage_st_header_log_id, t.st_forecast_group_name, 1 FROM ' + @stage_st_header_log + ' h
				INNER JOIN  ' + @each + ' t ON t.stage_st_header_log_id = h.stage_st_header_log_id
				LEFT JOIN #error_st_group m ON m.stage_st_header_log_id = h.stage_st_header_log_id
				LEFT JOIN static_data_value sdv ON sdv.code = t.st_forecast_group_name
				WHERE sdv.code IS NULL AND  m.stage_st_header_log_id IS NULL')
				
				-- Error handling: Non numeric values
				EXEC('INSERT INTO #error_st_group(stage_st_header_log_id, st_forecast_group_name, error_type)
				SELECT DISTINCT h.stage_st_header_log_id, t.st_forecast_group_name, 2 FROM ' + @stage_st_header_log + ' h
				INNER JOIN  ' + @each + ' t ON t.stage_st_header_log_id = h.stage_st_header_log_id
				LEFT JOIN #error_st_group m ON m.stage_st_header_log_id = h.stage_st_header_log_id -- non numeric error is not shown if grp marked as invalid
				WHERE ISNUMERIC(t.VALUE) = 0 AND  m.stage_st_header_log_id IS NULL')				

				-- Error handling: numeric with ',' is also treated as error value
				EXEC('INSERT INTO #error_st_group(stage_st_header_log_id, st_forecast_group_name, error_type)
				SELECT DISTINCT h.stage_st_header_log_id, t.st_forecast_group_name, 2 FROM ' + @stage_st_header_log + ' h
				INNER JOIN  ' + @each + ' t ON t.stage_st_header_log_id = h.stage_st_header_log_id
				LEFT JOIN #error_st_group m ON m.stage_st_header_log_id = h.stage_st_header_log_id
				WHERE CHARINDEX('','', t.value) <> 0 AND  m.stage_st_header_log_id IS NULL')				

				
				EXEC('DELETE t from ' + @each + ' t
					INNER JOIN #error_st_group m ON m.stage_st_header_log_id = t.stage_st_header_log_id
					')
					
				EXEC('INSERT INTO #ignored_st_data([type], [filename], [st_forecast_group_name], prior_data_count)
					SELECT ''Gas'' [type], h.filename, t.st_forecast_group_name, COUNT(*) prior_data_count FROM ' + @each + ' t 
					  INNER JOIN ' + @stage_st_header_log + ' h ON h.stage_st_header_log_id = t.stage_st_header_log_id
					  WHERE h.error_Code = ''0'' AND h.input_folder = ''Gas'' AND DATEADD(hh, Hr-1, CONVERT(DATETIME, term_start, 103)) < DATEADD(hh,6, CONVERT(VARCHAR(10),GETDATE(),121))
					  GROUP BY h.filename, t.st_forecast_group_name')

				EXEC('INSERT INTO #ignored_st_data([type], [filename], [st_forecast_group_name], prior_data_count)
					SELECT ''Power'' [type], h.filename, t.st_forecast_group_name, COUNT(*) prior_data_count FROM ' + @each + ' t 
					  INNER JOIN ' + @stage_st_header_log + ' h ON h.stage_st_header_log_id = t.stage_st_header_log_id
					  WHERE h.error_Code = ''0'' AND h.input_folder = ''Power'' AND 
					  CONVERT(DATETIME, term_start, 103) + '' '' + CONVERT(CHAR(5), DATEADD(minute, 15*(Hr-1), 0), 108) < CONVERT(VARCHAR(10),GETDATE(),121)
					  GROUP BY h.filename, t.st_forecast_group_name ')						  
			
				-- ignore prior data for Gas
				EXEC('DELETE t FROM ' + @each + ' t 
					  INNER JOIN ' + @stage_st_header_log + ' h ON h.stage_st_header_log_id = t.stage_st_header_log_id
					  WHERE h.error_Code = ''0'' AND h.input_folder = ''Gas'' AND 
					  DATEADD(hh, Hr-1, CONVERT(DATETIME, term_start, 103)) < DATEADD(hh,6, CONVERT(VARCHAR(10),GETDATE(),121))  ')						  

				-- ignore prior data for Power
				EXEC('DELETE t FROM ' + @each + ' t 
					  INNER JOIN ' + @stage_st_header_log + ' h ON h.stage_st_header_log_id = t.stage_st_header_log_id
					  WHERE h.error_Code = ''0'' AND h.input_folder = ''Power'' AND 
					  CONVERT(DATETIME, term_start, 103) + '' '' + CONVERT(CHAR(5), DATEADD(minute, 15*(Hr-1), 0), 108) < CONVERT(VARCHAR(10),GETDATE(),121)  ')
					  
				EXEC('INSERT INTO #ignored_st_data([type], [filename], [st_forecast_group_name], prior_data_count)
					SELECT ''Power'' [type], h.filename, t.st_forecast_group_name, COUNT(*) prior_data_count FROM ' + @each + ' t 
					  INNER JOIN ' + @stage_st_header_log + ' h ON h.stage_st_header_log_id = t.stage_st_header_log_id
					  INNER JOIN static_data_value sdv ON sdv.code = t.st_forecast_group_name
					  INNER JOIN exclude_st_forecast_dates e ON e.group_id = sdv.value_id
					  WHERE sdv.type_id = 19600 AND h.error_Code = ''0'' AND h.input_folder = ''Power'' AND 
					  CONVERT(DATETIME, t.term_start, 103) BETWEEN e.term_start AND ISNULL(e.term_end, e.term_start)
					  GROUP BY h.filename, t.st_forecast_group_name ')			
					  			  
				EXEC('DELETE t FROM ' + @each + ' t 
					  INNER JOIN ' + @stage_st_header_log + ' h ON h.stage_st_header_log_id = t.stage_st_header_log_id
					  INNER JOIN static_data_value sdv ON sdv.code = t.st_forecast_group_name
					  INNER JOIN exclude_st_forecast_dates e ON e.group_id = sdv.value_id
					  WHERE sdv.type_id = 19600 AND h.error_Code = ''0'' AND h.input_folder = ''Power'' AND 
					  CONVERT(DATETIME, t.term_start, 103) BETWEEN e.term_start AND ISNULL(e.term_end, e.term_start) ')
							  						  
	

		FETCH NEXT FROM c INTO @each 

		END

		CLOSE c
		DEALLOCATE c


		CREATE TABLE #data_count(row_count INT, TYPE VARCHAR(10) COLLATE DATABASE_DEFAULT)
		EXEC('INSERT INTO #data_count SELECT COUNT(*) row_count, ''gas'' FROM ' + @stage_st_forecast_hour)
		EXEC('INSERT INTO #data_count SELECT COUNT(*) row_count, ''power'' FROM ' + @stage_st_forecast_mins)
		
		CREATE TABLE #error_code ([type] CHAR(1) COLLATE DATABASE_DEFAULT)
		CREATE TABLE #imported_group ([name] VARCHAR(100) COLLATE DATABASE_DEFAULT)
		BEGIN TRAN
		
		IF EXISTS (SELECT 1 FROM #data_count WHERE row_count > 0 AND [type] = 'power')
		BEGIN
			INSERT INTO #error_code 
			EXEC spa_import_short_term_forecast_data @stage_st_forecast_mins, 'p', 'Import_st_15mins_Power_Data', @process_id, @user_login_id, @as_of_date, @stage_st_header_log

		END

		IF EXISTS (SELECT 1 FROM #data_count WHERE row_count > 0 AND [type] = 'gas')
		BEGIN
			INSERT INTO #error_code 
			EXEC spa_import_short_term_forecast_data @stage_st_forecast_hour, 'g', 'Import_st_hourly_Gas_Data', @process_id, @user_login_id, @as_of_date, @stage_st_header_log
		END		
		
		COMMIT
		

		--log errors
		EXEC('INSERT INTO source_system_data_import_status( Process_id, code, module, source, [type], [description])
			OUTPUT CASE WHEN INSERTED.[code] = ''Error'' THEN ''e'' ELSE ''s'' END  INTO #error_code
			SELECT ''' + @process_id + ''', ''Error'', ''Import Data'', l.filename, ''ST Forecast'', input_folder + '' Data Import: '' + l.error 
			FROM ' + @stage_st_header_log + ' l 
			WHERE l.error_code <> ''0'' ')

		EXEC('INSERT INTO source_system_data_import_status( Process_id, code, module, source, [type], [description])
			OUTPUT  ''e'' INTO #error_code
			SELECT ''' + @process_id + ''', ''Error'', ''Import Data'', l.filename, ''ST Forecast'',
			 input_folder + '' Data Import: '' +
			 CASE m.error_type 
			 WHEN 1 THEN 
			 CASE WHEN m.st_forecast_group_name = '''' THEN ''ST Forecast Group is blank'' ELSE ''ST Forecast Group: '' + m.st_forecast_group_name + '' does not exists'' END
			 WHEN 2 THEN
			 ''Non numeric value exists for ST Forecast Group: '' + m.st_forecast_group_name
			 ELSE ''Invalid File Format''
			 END	  
			FROM ' + @stage_st_header_log + ' l 
			INNER JOIN #error_st_group m ON m.stage_st_header_log_id = l.stage_st_header_log_id
			WHERE l.error_code = ''0'' ')

		-- log for files with all prior data, power
		EXEC('INSERT INTO source_system_data_import_status( Process_id, code, module, source, [type], [description])
			SELECT ''' + @process_id + ''', ''Success'', ''Import Data'', l.filename , ''ST Forecast'', 
			l.input_folder + '' Data Import: 0 rows imported.''
			FROM ' + @stage_st_header_log + ' l
			LEFT JOIN ' + @stage_st_forecast_mins + ' t ON t.stage_st_header_log_id = l.stage_st_header_log_id
			LEFT JOIN source_system_data_import_status s ON s.source = l.filename AND s.process_id = ''' + @process_id + '''
			WHERE t.stage_st_forecast_hour_id IS NULL AND l.error_code = ''0'' AND l.input_folder = ''Power'' AND s.source IS NULL
			')		

		-- log for files with all prior data, gas
		EXEC('INSERT INTO source_system_data_import_status( Process_id, code, module, source, [type], [description])
			SELECT ''' + @process_id + ''', ''Success'', ''Import Data'', l.filename , ''ST Forecast'', 
			l.input_folder + '' Data Import: 0 rows imported.''
			FROM ' + @stage_st_header_log + ' l
			LEFT JOIN ' + @stage_st_forecast_hour + ' t ON t.stage_st_header_log_id = l.stage_st_header_log_id
			LEFT JOIN source_system_data_import_status s ON s.source = l.filename AND s.process_id = ''' + @process_id + '''
			WHERE t.stage_st_forecast_hour_id IS NULL AND l.error_code = ''0'' AND l.input_folder = ''Gas'' AND s.source IS NULL
			')



		EXEC('INSERT INTO #error_files(filename, input_folder)
				  SELECT h.filename, h.input_folder FROM ' + @stage_st_header_log + ' h
				  INNER JOIN #error_st_group msg ON msg.stage_st_header_log_id = h.stage_st_header_log_id')

			
		--END TRY
		--BEGIN CATCH
		--	SET @caught = 1
		--	SET @desc = ERROR_MESSAGE()

		--	IF @@TRANCOUNT > 0
		--		ROLLBACK		
		--END CATCH
		
		
		IF @caught = 1 
		BEGIN
			SET @type = 'e'
		END
		ELSE
		BEGIN
			IF EXISTS(SELECT 1 FROM source_system_data_import_status WHERE Process_id = @process_id AND TYPE = 'Error')
				SET @type = 'e'	
			IF EXISTS (SELECT 1 FROM #error_code WHERE [type] = 'e')
				SET @type = 'e'
			ELSE 
				SET @type = 's'

		END
	
					 
	END

    --result set required to return to SSIS package to move error files from processed to error folder 	
	SELECT [filename], [input_folder] FROM #error_files


	SET @elapsed_sec = 0
	--wont work if ran package directly in debug mode.
	SELECT @elapsed_sec = CAST(DATEDIFF(second, create_ts, GETDATE()) AS FLOAT) FROM import_data_files_audit idfa WHERE idfa.process_id = @process_id
	SET @elapse_sec_text = CAST(CAST(@elapsed_sec/60 AS INT) AS VARCHAR) + ' Mins ' + CAST(@elapsed_sec - CAST(@elapsed_sec/60 AS INT) * 60 AS VARCHAR) + ' Secs'


	SELECT @desc = CASE WHEN @caught = 0 THEN 
				   'Short Term Forecast data import process completed on as of date ' + dbo.FNAUserDateFormat(GETDATE(), @user_login_id)
				   ELSE @desc END	
	  
	SET @url = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=exec spa_get_import_process_status ''' + @process_id + ''',''' + @user_login_id + ''''        
	SET @url_desc = '<a target="_blank" href="' + @url + '">' +
					  @desc 
					+ '.</a> <br>' + CASE WHEN (@type = 'e') THEN ' (ERRORS found)' ELSE '' END + ' [Elapse time: ' + @elapse_sec_text + ']'       

	IF @error_code <> 1
	BEGIN
		  --audit table log update total execution time
		  EXEC spa_import_data_files_audit
				@flag = 'u',
				@process_id = @process_id, 
				@status = @type,
				@elapsed_time = @elapsed_sec
				
		EXEC spa_message_board 'i', @user_login_id, NULL, 'Import Data', @url_desc, '', '', @type, 'Import Short Term Forecast'
		
		DECLARE @group_name VARCHAR(MAX) = ''
		SELECT @group_name = COALESCE(CAST(@group_name AS VARCHAR)+',' , '') + CAST(sdv.value_id AS VARCHAR) FROM #imported_group ig LEFT JOIN static_data_value sdv ON sdv.code = ig.[name]

		SET @group_name = NULLIF(@group_name, '')
		-- calculation logic
		SELECT @group_name = RIGHT(@group_name,LEN(@group_name)-1)
		
		EXEC spa_calc_st_forecast @group_name, NULL
			
	END
	ELSE IF @error_code = 1
	BEGIN
		DELETE i FROM import_data_files_audit i WHERE i.process_id = @process_id
		EXEC('DROP TABLE '+@stage_st_header_log)
		EXEC('DROP TABLE '+@stage_st_forecast_hour)
		EXEC('DROP TABLE '+@stage_st_forecast_mins)
	END
	
	--removing Ad-hoc message
	DELETE mb FROM message_board mb WHERE mb.job_name = 'ImportData_' + @process_id 

END


ELSE IF @flag = 'i'
BEGIN
	EXEC spa_print @stage_st_header_log
	SET @error_msg = ''
	
	--accept files only from Gas and Power folder
	IF EXISTS( SELECT 1 FROM ssis_configurations sc WHERE sc.ConfigurationFilter = 'PRJ_shortTermForecastImport'
			   AND sc.PackagePath LIKE '%PS_FolderName%' AND sc.configuredValue = @input_folder ) 
	BEGIN
		EXEC('INSERT INTO ' + @stage_st_header_log + '([filename], [input_folder] ,[error], [error_code], [create_user], [create_ts]) 
			  SELECT ''' + @filename + ''', ''' + @input_folder + ''', ''' + @error_msg + ''', ''' + @error_code + ''', ''' + @user_login_id +
			  ''', ''' + @as_of_date + '''  ') 

		SELECT CAST(IDENT_CURRENT(@stage_st_header_log) AS INT) log_row_id, @error_code error_code
	
	END
	
END

ELSE IF @flag = 'u'
BEGIN
	SET @error_msg = ''
		
	IF @error_code = '2' -- SSIS DFT component failure
	BEGIN
		SET @error_msg = 'Invalid File Format'
	END
		
	EXEC('UPDATE ' + @stage_st_header_log + ' SET error = ''' + @error_msg + ''', error_code = ''' + @error_code + 
		 ''' WHERE stage_st_header_log_id = ''' + @stage_st_header_log_id + ''' ' ) 

	SELECT @error_code error_code 
	
	
END

