IF OBJECT_ID(N'[dbo].[spa_west_power_message_board_handler]', N'P') IS NOT NULL

/****** Object:  StoredProcedure [dbo].[spa_west_power_message_board_handler]    Script Date: 10/20/2014 9:28:44 AM ******/
DROP PROCEDURE [dbo].[spa_west_power_message_board_handler]
GO

/****** Object:  StoredProcedure [dbo].[spa_west_power_message_board_handler]    Script Date: 10/20/2014 9:28:49 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ===========================================================================================================
-- Author: ssingh@pioneersolutionsglobal.com
-- Create date: 2012-05-15
-- Description: flag 'i' , Updates the message board every time If no file is found when Import is done manually. 
--				flag 'a', Updates the message board the last time the scheduled job runs If no file is found
--                        during the specified time frame during a day when Import is done via a scheduled job.
--	Params:
-- @flag CHAR(1) - Operation flag 'i' : Manual import ,'a' : Automatic Import
-- @process_id VARCHAR(50)- Process ID
-- @user_login_id VARCHAR(50) - UserID

-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_west_power_message_board_handler]
	@flag CHAR(1),
	@process_id VARCHAR(50),
	@user_login_id VARCHAR(50)
	--@role_type_value_id INT = 2

AS 

/*----------------------------------------------TEST SCRIPT-----------------------------------------------------*/
/*
DECLARE	@flag CHAR(1),
	@process_id VARCHAR(50),
	@user_login_id VARCHAR(50)
	
SET @flag ='a'
SET @process_id = '20120516_122357'
SET @user_login_id = 'farrms_admin'

--*/
/*----------------------------------------------END OF TEST SCRIPT----------------------------------------------*/

DECLARE @job_name VARCHAR(500)
DECLARE @start_ts	DATETIME
DECLARE @elapsed_sec FLOAT
DECLARE @tablename VARCHAR(100)
DECLARE @errorcode CHAR(2)
Declare @url varchar(500)
DECLARE  @desc varchar(500)


SET @tablename=(SELECT  code FROM  static_data_value WHERE  value_id=4008)
SET @job_name = 'WestPower_import_data_' + @process_id
SET @errorcode='e'
SELECT  @start_ts = isnull(min(create_ts),GETDATE()) FROM  import_data_files_audit WHERE  process_id = @process_id
SET @elapsed_sec = DATEDIFF(second, @start_ts, GETDATE())

BEGIN
	IF @flag = 'i'
	BEGIN
		INSERT  INTO  source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
		SELECT  @process_id,'Error','Import Data',@tablename,'Data Error','No data found.','Data may not be available in the source.Please check the data source.'
		INSERT  INTO  source_system_data_import_status_detail(process_id,source,type,[description]) 
		SELECT  @process_id,@tablename,'Data Error','Data may not be available in the source.Please check the data source.'
		--set @errorcode='e'


		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
		'&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''

		SELECT  @desc = '<a target="_blank" href="' + @url + '">' + 
		'Import process Completed for West Power Price on as of date:' + dbo.FNAUserDateFormat(getdate(), @user_login_id) + 
		CASE  WHEN  (@errorcode = 'e') then ' (ERRORS found)' ELSE  '' END  +
		'.Elapsed time:' + CAST(@elapsed_sec AS VARCHAR(1000)) + ' sec.
		</a>'
		EXEC  spa_message_board 'i', @user_login_id,
		NULL, 'Import.Data',
		@desc, '', '', @errorcode, @job_name,null,@process_id
	END
	
	IF @flag = 'a'
	BEGIN 
		--DECLARE @current_date VARCHAR(15)
		--DECLARE @next_run_date_time AS INT 
		--DECLARE @calculated_job_end_time AS INT
		
		--SELECT @current_date = CONVERT(VARCHAR(15),GETDATE(),111)

		--SELECT 
		--	@next_run_date_time = next_run_time
		--FROM 
		--msdb.dbo.sysjobs_view j INNER JOIN msdb.dbo.sysjobschedules js 
		--ON j.job_id = js.job_id
		--WHERE  j.name LIKE  '%- Import - West Power Price Curve'

		--SELECT 
		--	@calculated_job_end_time = sc.ConfiguredValue
		--FROM [ssis_configurations] sc 
		--WHERE sc.ConfigurationFilter = 'PKG_WestPowerPriceCurveImport' 
		--AND sc.PackagePath = '\Package.Variables[User::PS_JobEndTime].Properties[Value]'
		
		
		--Existence check if the price curve is already imported.
		--IF NOT EXISTS(SELECT 1 FROM source_system_data_import_status WHERE convert(VARCHAR(15),create_ts,111) = @current_date
		--AND  source ='West Power' AND [type] = 'Import' )
		--BEGIN 
		--	--Comparing the jobs end time and the specified end time for the job.
		--	IF @next_run_date_time = @calculated_job_end_time
		--	BEGIN 
				INSERT  INTO  source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
				SELECT  @process_id,'Error','Import Data',@tablename,'Data Error','No data found.','Data may not be available in the source.Please check the data source.'
				INSERT  INTO  source_system_data_import_status_detail(process_id,source,type,[description]) 
				SELECT  @process_id,@tablename,'Data Error','Data may not be available in the source.Please check the data source.'

				SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
				'&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''

				SELECT  @desc = '<a target="_blank" href="' + @url + '">' + 
				'Import process Completed for West Power Price on as of date:' + dbo.FNAUserDateFormat(getdate(), @user_login_id) + 
				CASE  WHEN  (@errorcode = 'e') then ' (ERRORS found)' ELSE  '' END  +
				'.Elapsed time:' + CAST(@elapsed_sec AS VARCHAR(1000)) + ' sec.
				</a>'
				
				EXEC  spa_message_board 'i', @user_login_id,
					NULL, 'Import.Data',
					@desc, '', '', @errorcode, @job_name,null,@process_id
					
				EXEC spa_NotificationUserByRole 2, @process_id, 'Import Data', @desc, @errorcode, @job_name, 1
					
			--To send email notification 
		--	EXEC spa_west_power_emailnotes_handler 'i',2
				DECLARE @template_params VARCHAR(5000) = ''
				DECLARE @user VARCHAR(100) = dbo.FNADBuser()	

				--replace template fields
				SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<TRM_IMPORT_SOURCE>', 'West Power')
				SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<TRM_IMPORT_AS_OF_DATE>', dbo.FNAUserDateFormat(GETDATE(), @user))
				SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<TRM_IMPORT_SOURCE_MSG>', 'Data has not been imported successfully.')

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
		--	END
		--END 
	END
	
	
	IF @flag = 'b'
	BEGIN 
 					
			--To send email notification 
		--	EXEC spa_west_power_emailnotes_handler 'i',2


-- send email once a day if no files emailed today.

-- DECLARE @next_run DATETIME = GETDATE()
-- ;WITH CTE AS (
--SELECT schedule_id, job_id, RIGHT('0'+CAST(next_run_time AS VARCHAR(6)),6) AS next_run_time, next_run_date
--FROM msdb.dbo.sysjobschedules)
--SELECT  TOP 1  @next_run =   STUFF(STUFF(STUFF(cast(next_run_date AS VARCHAR(10)) + cast(next_run_time AS VARCHAR(6)),13,0,':'),11,0,':'),9,0,' ')
--FROM msdb.dbo.sysjobs A ,CTE B
--WHERE A.job_id = B.job_id
--AND cast(cast(next_run_date as varchar(15)) as datetime) = CONVERT(VARCHAR(10),GETDATE(),101)-- same date
--AND next_run_time > REPLACE(SUBSTRING(CONVERT( VARCHAR(30) , GETDATE(),120),12,10),':','')-- compare time
--AND a.name LIKE '%- Import - Forward Price Upload'

 --select @next_run

--IF cast(convert(varchar(10), @next_run, 121) AS DATETIME) > cast(convert(varchar(10), getdate(),121) AS DATETIME)
IF GETDATE() >= CAST(CONVERT(VARCHAR(10),GETDATE(),121) + ' 23:00' AS DATETIME)
BEGIN
	
	IF NOT EXISTS( SELECT 1 FROM  import_data_files_audit WHERE dir_path = 'Forward Price Upload Import' 
	AND CONVERT(VARCHAR(10), as_of_date, 121) =  convert(varchar(10), getdate(),121) AND STATUS IN ('s', 'e') )
	BEGIN
				-- this should run just once a day if no emails are downloaded
				-- Throw error in messageboard for empty folder case. 
				INSERT  INTO  source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
				SELECT  @process_id,'Error','Import Data',@tablename,'Data Error','No data found.','Data may not be available in the source.Please check the data source.'
				INSERT  INTO  source_system_data_import_status_detail(process_id,source,type,[description]) 
				SELECT  @process_id,@tablename,'Data Error','Data may not be available in the source.Please check the data source.'

				SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
				'&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''

				SELECT  @desc = '<a target="_blank" href="' + @url + '">' + 
				'Import process Completed for Forward Price on as of date:' + dbo.FNAUserDateFormat(getdate(), @user_login_id) + 
				CASE  WHEN  (@errorcode = 'e') then ' (ERRORS found)' ELSE  '' END  +
				'.Elapsed time:' + CAST(@elapsed_sec AS VARCHAR(1000)) + ' sec.
				</a>'
				
				EXEC  spa_message_board 'i', @user_login_id,
					NULL, 'Import.Data',
					@desc, '', '', @errorcode, @job_name,null,@process_id
					
				EXEC spa_NotificationUserByRole 2, @process_id, 'Import Data', @desc, @errorcode, @job_name, 1
				
				-- Throw error in Emails as well for empty folder case	
				SET @template_params = ''
				SET @user = dbo.FNADBuser()	

				--replace template fields
				SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<TRM_IMPORT_SOURCE>', 'LADWP Forward Price')
				SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<TRM_IMPORT_AS_OF_DATE>', dbo.FNAUserDateFormat(GETDATE(), @user))
				SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<TRM_IMPORT_SOURCE_MSG>', '(Errors Found) Data may not be available in the source. Please check the data source.')

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
					@notes_object_name = NULL
	END
	
END
	EXEC spa_import_data_files_audit 'u', NULL, NULL, @process_id, 'Forward Price Upload Import', 'source_price_curve', NULL, 'w', @elapsed_sec

		--	END
		--END 
	END
	 
END 


