
IF OBJECT_ID(N'[dbo].[spa_west_power_update_message_board]', N'P') IS NOT NULL

/****** Object:  StoredProcedure [dbo].[spa_west_power_update_message_board]    Script Date: 10/20/2014 9:28:44 AM ******/
DROP PROCEDURE [dbo].[spa_west_power_update_message_board]
GO

/****** Object:  StoredProcedure [dbo].[spa_west_power_update_message_board]    Script Date: 10/20/2014 9:28:49 AM ******/
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

CREATE PROCEDURE [dbo].[spa_west_power_update_message_board]
	@flag CHAR(1),
	@process_id VARCHAR(50),
	@user_login_id VARCHAR(50),
	@role_type_value_id INT = 2

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
		SELECT  @process_id,'Error','Import Data',@tablename,'Data Error','No data found in staging table.','Please verify data'
		INSERT  INTO  source_system_data_import_status_detail(process_id,source,type,[description]) 
		SELECT  @process_id,@tablename,'Data Error','Staging Table is empty.'
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
		DECLARE @current_date VARCHAR(15)
		DECLARE @next_run_date_time AS INT 
		DECLARE @calculated_job_end_time AS INT
		
		SELECT @current_date = CONVERT(VARCHAR(15),GETDATE(),111)

		SELECT 
			@next_run_date_time = next_run_time
		FROM 
		msdb.dbo.sysjobs_view j INNER JOIN msdb.dbo.sysjobschedules js 
		ON j.job_id = js.job_id
		WHERE  j.name LIKE  '%- Import - West Power Price Curve'

		SELECT 
			@calculated_job_end_time = sc.ConfiguredValue
		FROM [ssis_configurations] sc 
		WHERE sc.ConfigurationFilter = 'PKG_WestPowerPriceCurveImport' 
		AND sc.PackagePath = '\Package.Variables[User::PS_JobEndTime].Properties[Value]'
		
		
		--Existence check if the price curve is already imported.
		IF NOT EXISTS(SELECT 1 FROM source_system_data_import_status WHERE convert(VARCHAR(15),create_ts,111) = @current_date
		AND  source ='West Power' AND [type] = 'Import' )
		BEGIN 
			--Comparing the jobs end time and the specified end time for the job.
			IF @next_run_date_time = @calculated_job_end_time
			BEGIN 
				INSERT  INTO  source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
				SELECT  @process_id,'Error','Import Data',@tablename,'Data Error','No data found in staging table.','Please verify data'
				INSERT  INTO  source_system_data_import_status_detail(process_id,source,type,[description]) 
				SELECT  @process_id,@tablename,'Data Error','Staging Table is empty.'

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
					
			--To send email notification 
				
			DECLARE @user VARCHAR(100)
			
			SELECT @user = dbo.FNADBuser()	
			SELECT @desc = 'Price Import for LADWP -Power completed for as of date:' + dbo.FNAUserDateFormat(GETDATE(), @user) + 
								' (ERRORS found)'	
									
			INSERT INTO email_notes(
			[internal_type_value_id], 
			[category_value_id],
			[notes_object_id],
			[notes_object_name],
			[send_status],
			[active_flag], 
			[notes_subject],  
			[notes_text],  
			[send_from],  
			[send_to],  
			[attachment_file_name]  )

			SELECT DISTINCT
			3,
			4,
			1,
			'',
			'n',
			'y',
			'CRITICAL:' + @desc ,
			@desc,
			'noreply@pioneersolutionsglobal.com',
			user_emal_add,
			NULL
			FROM dbo.application_role_user 
			INNER JOIN dbo.application_security_role ON dbo.application_role_user.role_id = dbo.application_security_role.role_id     
			INNER JOIN dbo.application_users ON dbo.application_role_user.user_login_id = dbo.application_users.user_login_id    
			WHERE (dbo.application_users.user_active = 'y') AND (dbo.application_security_role.role_type_value_id = @role_type_value_id) 
			AND user_emal_add IS NOT NULL
			GROUP BY dbo.application_users.user_login_id,dbo.application_users.user_emal_add 
			END
		END 
	END 
	
	
	IF @flag = 'b' -- For Forward Price Upload
	BEGIN 
		SELECT @current_date = CONVERT(VARCHAR(15),GETDATE(),111)
		SET @tablename='ForwardPrice'

		SELECT 
			@next_run_date_time = next_run_time
		FROM 
		msdb.dbo.sysjobs_view j INNER JOIN msdb.dbo.sysjobschedules js 
		ON j.job_id = js.job_id
		WHERE  j.name LIKE  '%- Import - Forward Price Upload'

		SELECT 
			@calculated_job_end_time = sc.ConfiguredValue
		FROM [ssis_configurations] sc 
		WHERE sc.ConfigurationFilter = 'PKG_ForwardPriceUpload' 
		AND sc.PackagePath = '\Package.Variables[User::PS_JobEndTime].Properties[Value]'
		
		
		--Existence check if the price curve is already imported.
		IF NOT EXISTS(SELECT 1 FROM source_system_data_import_status WHERE convert(VARCHAR(15),create_ts,111) = @current_date
		AND  source ='ForwardPrice' --AND [type] = 'Import' 
		)
		BEGIN 
			--Comparing the jobs end time and the specified end time for the job.
			IF @next_run_date_time = @calculated_job_end_time
			BEGIN 
				INSERT  INTO  source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
				SELECT  @process_id,'Error','Import Data',@tablename,'Data Error','No data found in staging table.','Please verify data'
				INSERT  INTO  source_system_data_import_status_detail(process_id,source,type,[description]) 
				SELECT  @process_id,@tablename,'Data Error','Staging Table is empty.'

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
					
			--To send email notification 
				
		
			SELECT @user = dbo.FNADBuser()	
			SELECT @desc = 'Price Import for LADWP -Power completed for as of date:' + dbo.FNAUserDateFormat(GETDATE(), @user) + 
								' (ERRORS found)'	
									
			INSERT INTO email_notes(
			[internal_type_value_id], 
			[category_value_id],
			[notes_object_id],
			[notes_object_name],
			[send_status],
			[active_flag], 
			[notes_subject],  
			[notes_text],  
			[send_from],  
			[send_to],  
			[attachment_file_name]  )

			SELECT DISTINCT
			3,
			4,
			1,
			'',
			'n',
			'y',
			'CRITICAL:' + @desc ,
			@desc,
			'noreply@pioneersolutionsglobal.com',
			user_emal_add,
			NULL
			FROM dbo.application_role_user 
			INNER JOIN dbo.application_security_role ON dbo.application_role_user.role_id = dbo.application_security_role.role_id     
			INNER JOIN dbo.application_users ON dbo.application_role_user.user_login_id = dbo.application_users.user_login_id    
			WHERE (dbo.application_users.user_active = 'y') AND (dbo.application_security_role.role_type_value_id = @role_type_value_id) 
			AND user_emal_add IS NOT NULL
			GROUP BY dbo.application_users.user_login_id,dbo.application_users.user_emal_add 
			END
		END 
	END
	
END



