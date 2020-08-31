
IF OBJECT_ID(N'[dbo].[spa_load_price_curve_west_power]', N'P') IS NOT NULL

/****** Object:  StoredProcedure [dbo].[spa_load_price_curve_west_power]    Script Date: 10/20/2014 9:28:44 AM ******/
DROP PROCEDURE [dbo].[spa_load_price_curve_west_power]
GO

/****** Object:  StoredProcedure [dbo].[spa_load_price_curve_west_power]    Script Date: 10/20/2014 9:28:49 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- ===========================================================================================================
-- Author: ssingh@pioneersolutionsglobal.com
-- Create date: 2012-03-27
-- Description: flag 'c' ,Creates a loading table while importing West_Power excel files. 
--				flag 'i', Insert data into staging table from loading table.
--
--	Params:
-- @flag CHAR(1) - Operation flag
-- @process_id VARCHAR(50)- Process ID
-- @user_login_id VARCHAR(50) - UserID
-- @temp_table_name VARCHAR(256) - Staging Table
-- @load_data  VARCHAR (256) - loading table where data is inserted directly from excel source as it is . 
--	@table_code VARCHAR(32) - TableCode
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_load_price_curve_west_power]
	@flag CHAR(1),
	@process_id VARCHAR(50)= NULL,
	@user_login_id VARCHAR(50)= NULL,
	@temp_table_name varchar(256) = NULL,
	@load_data  VARCHAR (256) = NULL,
	@table_code VARCHAR(32) = NULL,
	@price_curve_filename AS VARCHAR(200)= NULL 
AS 

/*********************************************Test Data Start*********************************************************************/
/*
DECLARE	@flag				CHAR(1),
        @process_id			VARCHAR(50),
		@user_login_id		VARCHAR(50),
		@temp_table_name	VARCHAR (256),
		@load_data          VARCHAR (256),
		@table_code			VARCHAR(32) 
		
SET @flag = 'm'	
SET @process_id = '20120515_121932'
SET @user_login_id = 'farrms_admin'
SET @temp_table_name = ''
SET @load_data = NULL
SET @table_code = '4008'
--*/
/*********************************************Test Data End *********************************************************************/

BEGIN
	
	DECLARE @sql VARCHAR(MAX)
	DECLARE @sql_select VARCHAR(MAX)
	DECLARE @job_name VARCHAR(256)
	DECLARE @current_ts DATETIME = GETDATE()
	
	SET @job_name = 'WestPower_import_data_' + @process_id
	IF @load_data IS NULL
		SELECT @load_data = dbo.FNAProcessTableName('load_price_curve_west_power', @user_login_id, @process_id)
	--SELECT @temp_table_name = dbo.FNAProcessTableName('source_price_curve', @user_login_id, @process_id)
	
		DECLARE @count			INT = NULL 
		DECLARE @errorcode		CHAR(1) = NULL 
		DECLARE @url			VARCHAR(5000) = NULL 
		DECLARE @desc			VARCHAR(8000) = NULL 
		DECLARE @start_ts   	DATETIME = NULL 
		DECLARE @elapsed_sec	FLOAT = NULL 
		DECLARE @template_params VARCHAR(5000) = ''
		DECLARE @user VARCHAR(100) = dbo.FNADBuser()	
		
	IF @flag = 'c' -- create loading table 
	BEGIN
		SET @sql = 'IF OBJECT_ID(''' + @load_data + ''') IS NOT NULL
			DROP TABLE ' + @load_data 
		EXEC(@sql)
		
		SET @sql = 
			'CREATE TABLE ' + @load_data + 
			'(
				serial_no INT IDENTITY (1,1),
				maturity_date NVARCHAR(255),
				midc_bid NVARCHAR (255),
				midc_offer NVARCHAR(255),
				sp_bid NVARCHAR(255),
				sp_offer NVARCHAR(255),
				np_bid  NVARCHAR(255),
				np_offer NVARCHAR(255),
				pv_bid NVARCHAR(255),
				pv_offer NVARCHAR(255),
				mead_bid NVARCHAR(255),
				mead_offer NVARCHAR (255)
			)'
		EXEC(@sql)
		PRINT(@sql)	
	END
	
	-- staging table for Forward Price Upload 
	IF @flag = 'l'
	BEGIN

		SELECT @load_data = dbo.FNAProcessTableName('power_forward_price', @user_login_id, @process_id)
		SET @sql = 'IF OBJECT_ID(''' + @load_data + ''') IS NOT NULL
		DROP TABLE ' + @load_data 
		EXEC(@sql)
		
		SET @sql = 
			'CREATE TABLE ' + @load_data + 
			'(
				id INT IDENTITY (1,1),
				file_type INT,
				title VARCHAR(255),
				region VARCHAR (255),
				as_of_date VARCHAR(255),
				term NVARCHAR(255),
				curve NVARCHAR(255),
				value VARCHAR(255),
				file_name VARCHAR(255)
			)'
		EXEC(@sql)
		PRINT(@sql)	
	END 

	IF @flag = 't' -- truncate loading table once data is transferred to staging table 
	 BEGIN 
	 	SET @sql = 'IF OBJECT_ID(''' + @load_data + ''') IS NOT NULL
			TRUNCATE TABLE ' + @load_data 
		PRINT @sql
		EXEC(@sql)
	 END 
	
	IF @flag = 'i'
	BEGIN
		SELECT @sql_select = dbo.FNAPriceCurveByCurveID('MID-C', @load_data)
		SET @sql =
		'INSERT INTO ' + @temp_table_name + 
		'(source_curve_def_id, source_system_id, as_of_date, Assessment_curve_type_value_id, curve_source_value_id, maturity_date, maturity_hour, curve_value, is_dst, table_code)' 
		+ 'EXEC (''' + @sql_select +''')'
		PRINT @sql
		EXEC(@sql)
		
		
		SELECT @sql_select = dbo.FNAPriceCurveByCurveID('SP15', @load_data)
		SET @sql =
		'INSERT INTO ' + @temp_table_name + 
		'(source_curve_def_id, source_system_id, as_of_date, Assessment_curve_type_value_id, curve_source_value_id, maturity_date, maturity_hour, curve_value, is_dst, table_code)' 
		+ 'EXEC (''' + @sql_select +''')'
		PRINT @sql
		EXEC(@sql)

		
		SELECT @sql_select = dbo.FNAPriceCurveByCurveID('NP15', @load_data)
		SET @sql =
		'INSERT INTO ' + @temp_table_name + 
		'(source_curve_def_id, source_system_id, as_of_date, Assessment_curve_type_value_id, curve_source_value_id, maturity_date, maturity_hour, curve_value, is_dst, table_code)' 
		+ 'EXEC (''' + @sql_select +''')'
		PRINT @sql
		EXEC(@sql)
		
		SELECT @sql_select = dbo.FNAPriceCurveByCurveID('PV', @load_data)
		SET @sql =
		'INSERT INTO ' + @temp_table_name + 
		'(source_curve_def_id, source_system_id, as_of_date, Assessment_curve_type_value_id, curve_source_value_id, maturity_date, maturity_hour, curve_value, is_dst, table_code)' 
		+ 'EXEC (''' + @sql_select +''')'
		PRINT @sql
		EXEC(@sql)
			
		SELECT @sql_select = dbo.FNAPriceCurveByCurveID('MEAD', @load_data)
		SET @sql =
		'INSERT INTO ' + @temp_table_name + 
		'(source_curve_def_id, source_system_id, as_of_date, Assessment_curve_type_value_id, curve_source_value_id, maturity_date, maturity_hour, curve_value, is_dst, table_code)' 
		+ 'EXEC (''' + @sql_select +''')'
		PRINT @sql
		EXEC(@sql)
		
		
		RETURN		
	END 	

		
	IF @flag = 'j'
	BEGIN
		--SELECT @sql_select = dbo.FNAPriceCurveByCurveID('MID-C', @load_data)
		SET @sql =
		'
		INSERT INTO ' + @temp_table_name + 
		'(source_curve_def_id, source_system_id, as_of_date, Assessment_curve_type_value_id, curve_source_value_id, maturity_date, maturity_hour, curve_value, is_dst, table_code)
		
SELECT spcd.curve_id, 2, t.as_of_date, 77, 4500, t.term, NULL, t.value, 0, 4008 
FROM source_price_curve_def spcd		
INNER JOIN ' + @load_data + ' t ON t.curve = spcd.market_value_id
AND spcd.curve_tou = CASE WHEN title LIKE ''%On Peak%'' THEN 18900 WHEN title LIKE ''%Off Peak%'' THEN 18901 ELSE NULL END
WHERE spcd.granularity = 980 AND file_name = ''' + @price_curve_filename + '''		
		
	 ' 

	PRINT @sql
	EXEC(@sql)

			UPDATE import_data_files_audit SET imp_file_name = CASE WHEN NULLIF(imp_file_name, '') IS NULL THEN @price_curve_filename WHEN CHARINDEX(@price_curve_filename, imp_file_name) > 0 THEN '' ELSE imp_file_name + ',' + @price_curve_filename END WHERE process_id=@process_id

	--EXEC('TRUNCATE TABLE ' + @load_data)
	--	EXEC('select * from ' + @temp_table_name+ ' order by source_curve_def_id, maturity_date')
	END



	IF @flag = 'n' -- Import to main table for Forward Price
	BEGIN
			SET @job_name = 'ForwardPrice_import_data_' + @process_id
			CREATE TABLE #as_of_date(aod_from VARCHAR(30), aod_to VARCHAR(30))
			DECLARE @as_of_date_from VARCHAR(30), @as_of_date_to VARCHAR(30)
	BEGIN TRY 
	
		EXEC(' INSERT INTO #as_of_date(aod_from, aod_to) SELECT MIN(as_of_date), MAX(as_of_date) FROM ' + @temp_table_name)
		SELECT @as_of_date_from = CONVERT(VARCHAR(10), CAST(aod_from AS DATETIME), 121), @as_of_date_to = CONVERT(VARCHAR(10), CAST(aod_to AS DATETIME), 121) FROM #as_of_date
		
		
		-- inserting error rows with no matching market_value_id and tou
		EXEC('
				INSERT INTO ' + @temp_table_name + 
		'(source_curve_def_id, source_system_id, as_of_date, Assessment_curve_type_value_id, curve_source_value_id, maturity_date, maturity_hour, bid_value, ask_value, curve_value, is_dst, table_code)
		SELECT spcd.source_curve_def_id,2, r.as_of_date,77, 4500, r.term,NULL,NULL,NULL,r.value,0,4008 
		FROM ' + @load_data + ' r
		left JOIN source_price_curve_def spcd ON spcd.market_value_id = r.curve AND spcd.curve_tou = 18900 
		WHERE spcd.source_curve_def_id IS NULL AND  r.title LIKE ''%On Peak%'' 
			UNION ALL
		SELECT spcd.source_curve_def_id,2, r.as_of_date,77, 4500, r.term,NULL,NULL,NULL,r.value,0,4008 
		FROM ' + @load_data + ' r
		left JOIN source_price_curve_def spcd ON spcd.market_value_id = r.curve AND spcd.curve_tou = 18901 
		WHERE spcd.source_curve_def_id IS NULL AND  r.title LIKE ''%Off Peak%'' 
		')
		
		
		EXEC spa_import_data_job @temp_table_name, @table_code, @job_name, @process_id, @user_login_id, 'n', NULL, NULL, NULL 
		--insert into message board for Role type users 

		-- Error messaging for market value ID and tou that are not mapped.
		EXEC('
				INSERT  INTO  source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
		SELECT DISTINCT ''' +  @process_id + ''',''Error'',''Import Data'',''ForwardPrice'',''Data Error'',''No curve could be mapped for '' + r.curve + '' Market Value ID /		OnPeak tou'',''Please verify data''
		FROM ' + @load_data + ' r
		left JOIN source_price_curve_def spcd ON spcd.market_value_id = r.curve AND spcd.curve_tou = 18900 
		WHERE spcd.source_curve_def_id IS NULL AND  r.title LIKE ''%On Peak%'' 
		
				INSERT  INTO  source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
		SELECT DISTINCT ''' +  @process_id + ''',''Error'',''Import Data'',''ForwardPrice'',''Data Error'',''No curve could be mapped for '' + r.curve + '' Market Value ID /		OffPeak tou'',''Please verify data''
		FROM ' + @load_data + ' r
		left JOIN source_price_curve_def spcd ON spcd.market_value_id = r.curve AND spcd.curve_tou = 18901 
		WHERE spcd.source_curve_def_id IS NULL AND  r.title LIKE ''%Off Peak%'' 
		
		')
	
					
		SELECT @count=COUNT(*) FROM source_system_data_import_status WHERE process_id=@process_id AND ([type]='Error' OR [type]='Data Error'OR [type]='Data Warning')
		IF @count >0
		BEGIN
			SET @errorcode='e'
		END
		ELSE
		BEGIN
			SET @errorcode='s'
		END
			
		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
		'&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''

		SELECT  @start_ts = ISNULL(MIN(create_ts),GETDATE()) FROM import_data_files_audit WHERE process_id = @process_id
		SET @elapsed_sec = DATEDIFF(SECOND, @start_ts, GETDATE())

		SELECT @desc = '<a target="_blank" href="' + @url + '">' + 
			'Import process Completed for Forward Price on as of date:' + dbo.FNAUserDateFormat(GETDATE(), @user_login_id) 
			+ CASE WHEN (@errorcode = 'e') THEN ' (ERRORS found)' ELSE '' END 
			+ '.Elapsed time:' + CAST(@elapsed_sec AS VARCHAR(1000)) + ' sec.</a>' 
		
		EXEC spa_save_derived_curve_value_notifications 'c', @as_of_date_from, @as_of_date_to
	
		EXEC spa_NotificationUserByRole 2, @process_id, 'Import Data', @desc, @errorcode, @job_name, 1
	END TRY 
	BEGIN CATCH
	
		SET @errorcode='e'
		--replace template fields
		SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<TRM_IMPORT_SOURCE>', 'Forward Price')
		SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<TRM_IMPORT_AS_OF_DATE>', dbo.FNAUserDateFormat(GETDATE(), @user))
		SET  @template_params = dbo.FNABuildNameValueXML(@template_params, '<TRM_IMPORT_SOURCE_MSG>', ISNULL(ERROR_MESSAGE(),  'Data has not been imported successfully.Exception occured.'))

		--call spa_email_notes
		
		EXEC spa_email_notes
			@flag = 'b',
			@role_type_value_id = 2,
			@email_module_type_value_id = 17805,
			@send_status = 'n',
			@active_flag = 'y',
			@template_params = @template_params,
			@internal_type_value_id = 3,
			@category_value_id = 4,
			@notes_object_id = 1,
			@notes_object_name = null
 
	END CATCH

	UPDATE import_data_files_audit SET [status] = @errorcode, elapsed_time = @elapsed_sec WHERE Process_ID = @process_id
	
	END	



	
	IF @flag = 'm' -- Import to main table
	BEGIN
	BEGIN TRY 
		EXEC spa_import_data_job @temp_table_name, @table_code, @job_name, @process_id, @user_login_id, 'n', NULL, NULL, NULL 
		--insert into message board for Role type users 
		SET @count = NULL
		SET @errorcode = NULL
		SET @url = NULL
		SET @desc = NULL
		SET @start_ts = NULL
		SET @elapsed_sec = NULL
		
		SELECT @count=COUNT(*) FROM source_system_data_import_status WHERE process_id=@process_id AND ([type]='Error' OR [type]='Data Error'OR [type]='Data Warning')
		IF @count >0
		BEGIN
			SET @errorcode='e'
		END
		ELSE
		BEGIN
			SET @errorcode='s'
		END
			
		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
		'&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''

		SELECT  @start_ts = ISNULL(MIN(create_ts),GETDATE()) FROM import_data_files_audit WHERE process_id = @process_id
		SET @elapsed_sec = DATEDIFF(SECOND, @start_ts, GETDATE())

		SELECT @desc = '<a target="_blank" href="' + @url + '">' + 
			'Import process Completed for West Power Price on as of date:' + dbo.FNAUserDateFormat(GETDATE(), @user_login_id) 
			+ CASE WHEN (@errorcode = 'e') THEN ' (ERRORS found)' ELSE '' END 
			+ '.Elapsed time:' + CAST(@elapsed_sec AS VARCHAR(1000)) + ' sec.</a>' 
			
		EXEC spa_NotificationUserByRole 2, @process_id, 'Import Data', @desc, @errorcode, @job_name, 1
	END TRY 
	BEGIN CATCH
		
		--replace template fields
		SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<TRM_IMPORT_SOURCE>', 'West Power')
		SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<TRM_IMPORT_AS_OF_DATE>', dbo.FNAUserDateFormat(GETDATE(), @user))
		SET  @template_params = dbo.FNABuildNameValueXML(@template_params, '<TRM_IMPORT_SOURCE_MSG>', ISNULL(ERROR_MESSAGE(),  'Data has not been imported successfully.'))

		--call spa_email_notes
		
		EXEC spa_email_notes
			@flag = 'b',
			@role_type_value_id = 2,
			@email_module_type_value_id = 17805,
			@send_status = 'n',
			@active_flag = 'y',
			@template_params = @template_params,
			@internal_type_value_id = 3,
			@category_value_id = 4,
			@notes_object_id = 1,
			@notes_object_name = null
 
	END CATCH
	END		
	
	--IF @flag = 'e' -- to check existence of a file in the database before downloading the mail attachment.
	--BEGIN 
	--	DECLARE @description VARCHAR(8000)
	--	--trasforming the values of column description to a row 
	--	SELECT @description = STUFF((
	--					SELECT ',' + [description] FROM import_data_files_audit 
	--					WHERE convert(varchar,create_ts,111) = convert(varchar,GETDATE(),111)
	--					AND  [description] IS NOT NULL 
	--					FOR XML PATH('')
	--				), 1, 1, '')		
	--	SELECT 1 AS [file_exists] FROM dbo.SplitCommaSeperatedValues(@description) scsv WHERE scsv.Item = @price_curve_filename	
	--END 
	
	IF @flag = 'e' -- to check existence of a file in the database before downloading the mail attachment.
	BEGIN 
		DECLARE @description VARCHAR(8000)
		--trasforming the values of column description to a row 
		SELECT @description = STUFF((
						SELECT ',' + imp_file_name FROM import_data_files_audit 
						WHERE convert(varchar,create_ts,111) = convert(varchar,GETDATE(),111)
						AND  imp_file_name IS NOT NULL 
						FOR XML PATH('')
					), 1, 1, '')		
		SELECT 1 AS [file_exists] FROM dbo.SplitCommaSeperatedValues(@description) scsv WHERE scsv.Item = @price_curve_filename	
	END 
	
	IF @flag = 't'
	BEGIN
		DECLARE @job_time VARCHAR(20)
		DECLARE @time_zone INT 
		
		--Get the job run time
		SELECT @job_time =
		CAST(CONVERT(DATE, CONVERT(VARCHAR(8), js.next_run_date), 120) AS VARCHAR(10)) + ' ' +
		CAST(STUFF(STUFF(STUFF(next_run_time, 1, 0, REPLICATE('0', 6 - LEN(next_run_time))),3,0,':'),6,0,':')  AS VARCHAR(10))
		FROM 
		msdb.dbo.sysjobs_view j 
		JOIN msdb.dbo.sysjobschedules js 
		ON j.job_id = js.job_id
		WHERE  j.name LIKE  '%- Import - West Power Price Curve'

		SELECT @time_zone = timezone_id FROM time_zones WHERE  TIMEZONE_NAME = '(GMT -6:00) Central Time (US & Canada), Mexico City'
		
		/*
		* Get the time range for emails to be downloaded in UTC
		* We are only to download email that have been sent exactly within the 24 hr range before the job is triggered.
		* For eg:
		* If the job is scheduled to run at 2014-02-21 23:04  then email range in UTC is as follows:
		*	email_range_start       |	email_range_end
			2014-02-21 05:14:00.000		2014-02-22 05:04:00.000
		* The Job run Time from the sysjobschedules is considered as the comparision point instead of the server time 
		  when the job is triggerd so that we pick the correct time range when the job is triggered manually. If the server time  
		  itself is considered than the logic will even download data of the prior day
		* */
		SELECT DATEADD(mi,10,DATEADD(dd, -1, [dbo].[FNAGetUTCTTime](@job_time,@time_zone)))AS [email_range_start]
		, [dbo].[FNAGetUTCTTime](@job_time, @time_zone) AS [email_range_end]
	END

	IF @flag = 'u'
	BEGIN
		
		-- initiate import audit log,
		IF NOT EXISTS (SELECT 1 FROM import_data_files_audit WHERE process_id = @process_id)
		BEGIN
			EXEC spa_import_data_files_audit 'i', @current_ts, NULL, @process_id, 'Forward Price Upload Import', 'source_price_curve', @current_ts, 'p', NULL
		END
			
	 	SET @sql = 'IF OBJECT_ID(''' + @load_data + ''') IS NOT NULL
			TRUNCATE TABLE ' + @load_data 
		PRINT @sql
		EXEC(@sql)

		--Get the job run time
		SELECT TOP 1 @job_time =
		CAST(CONVERT(DATE, CONVERT(VARCHAR(8), js.next_run_date), 120) AS VARCHAR(10)) + ' ' +
		CAST(STUFF(STUFF(STUFF(next_run_time, 1, 0, REPLICATE('0', 6 - LEN(next_run_time))),3,0,':'),6,0,':')  AS VARCHAR(10))
		FROM 
		msdb.dbo.sysjobs_view j 
		JOIN msdb.dbo.sysjobschedules js 
		ON j.job_id = js.job_id
		WHERE  j.name LIKE  '%- Import - Forward Price Upload'

		--SELECT @time_zone = timezone_id FROM time_zones WHERE  TIMEZONE_NAME = '(GMT -6:00) Central Time (US & Canada), Mexico City'
		SELECT @time_zone = av.var_value FROM adiha_default_codes_values av 
		INNER JOIN adiha_default_codes ac ON ac.default_code_id = av.default_code_id
		WHERE ac.default_code_id = 36 AND av.instance_no = 1 AND av.seq_no = 1

		/*
		* Get the time range for emails to be downloaded in UTC
		* We are only to download email that have been sent exactly within the 24 hr range before the job is triggered.
		* For eg:
		* If the job is scheduled to run at 2014-02-21 23:04  then email range in UTC is as follows:
		*	email_range_start       |	email_range_end
			2014-02-21 05:14:00.000		2014-02-22 05:04:00.000
		* The Job run Time from the sysjobschedules is considered as the comparision point instead of the server time 
		  when the job is triggerd so that we pick the correct time range when the job is triggered manually. If the server time  
		  itself is considered than the logic will even download data of the prior day
		* */

		DECLARE @tmp_sp_help_jobhistory TABLE 
		        (
		            instance_id INT NULL,
		            job_id UNIQUEIDENTIFIER NULL,
		            job_name SYSNAME NULL,
		            step_id INT NULL,
		            step_name SYSNAME NULL,
		            sql_message_id INT NULL,
		            sql_severity INT NULL,
		            MESSAGE NVARCHAR(4000) NULL,
		            run_status INT NULL,
		            run_date INT NULL,
		            run_time INT NULL,
		            run_duration INT NULL,
		            operator_emailed SYSNAME NULL,
		            operator_netsent SYSNAME NULL,
		            operator_paged SYSNAME NULL,
		            retries_attempted INT NULL,
		            SERVER SYSNAME NULL
		        )
		
		INSERT INTO @tmp_sp_help_jobhistory
		EXEC msdb.dbo.sp_help_jobhistory @mode = 'FULL'
		     --select * from @tmp_sp_help_jobhistory 
		     
		
		DECLARE @last_ran_time DATETIME = CONVERT(VARCHAR(10),GETDATE(),121)

		SELECT TOP 1 @last_ran_time = dt.run_datetime
		FROM @tmp_sp_help_jobhistory  sjh
		INNER JOIN msdb.dbo.sysjobs_view sj ON sjh.job_id = sj.job_id
		CROSS APPLY (
			SELECT CONVERT(DATETIME, RTRIM(run_date)) + ((run_time / 10000 * 3600) + ((run_time % 10000) / 100 * 60) + (run_time % 10000) % 100) / (86399.9964) AS run_datetime
		) dt
		WHERE sjh.step_id = 0 AND sjh.run_status = 1 AND sj.name LIKE '%- Import - Forward Price Upload'  -- = N'TRMTracker_Master_LADWP - Import - Forward Price Upload'
			AND dt.run_datetime < = DATEADD(minute, -1, GETDATE())
		ORDER BY sjh.run_date DESC, sjh.run_time DESC
		
		--SELECT @last_ran_time
		SELECT  @last_ran_time  AS [email_range_start] -- [dbo].[FNAGetUTCTTime](@last_ran_time,23) AS [email_range_start]
		, [dbo].[FNAGetUTCTTime](@job_time, @time_zone) AS [email_range_end]
		
		--SELECT DATEADD(mi,10,DATEADD(dd, -1, [dbo].[FNAGetUTCTTime](@job_time,@time_zone)))AS [email_range_start]
		--, [dbo].[FNAGetUTCTTime](@job_time, @time_zone) AS [email_range_end]
	END

END

