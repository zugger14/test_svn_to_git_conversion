IF OBJECT_ID('[dbo].[spa_import_data]', 'p') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_import_data]
GO 

CREATE PROCEDURE [dbo].[spa_import_data]
	@PathFileName		VARCHAR(MAX) = '',
	@tablename			VARCHAR(100) = '',
	@user_login_id		VARCHAR(50) = NULL,
	@import_format		CHAR(1) = 'n',
	@process_id			VARCHAR(50) = NULL,
	@facility_ids		VARCHAR(MAX) = '',
	@purge_data			BIT = 0,
	@file_name			VARCHAR(500) = ''
AS
	DECLARE @spa       VARCHAR(MAX)
	DECLARE @job_name  VARCHAR(100)
	DECLARE @table_no  VARCHAR(100)
	--DECLARE @process_id varchar(50)
	
	IF @process_id IS NULL
	    SET @process_id = REPLACE(NEWID(), '-', '_')
	
	IF NULLIF(@user_login_id, '') IS NULL
	    SET @user_login_id = dbo.FNADBUser()
	
	SET @job_name = 'importdata_' + @tablename + '_' + @process_id
	--select * from static_data_value where type_id IN (5450,4000)
	
	IF @file_name IS NULL
	    SET @file_name = ''
	
	IF ISNUMERIC(@tablename) = 1
	BEGIN
	    SET @table_no = @tablename 
	    SELECT @tablename = code FROM dbo.static_data_value WHERE  value_id = CAST(@table_no AS INT)
	END
	ELSE
	    SELECT @table_no = value_id FROM dbo.static_data_value WHERE  code = @tablename
	
	IF @tablename = 'rec_loadstar' AND @import_format = 'n'
	    SET @spa = 'spa_import_mv90_data  ''' + @PathFileName + ''',''' + @tablename + ''', ''' 
					+ @job_name + ''', ''' + @process_id + ''',''' + @user_login_id + ''''
	
	ELSE IF @tablename = 'rec_loadstar' AND @import_format = 'y'
	    SET @spa = 'spa_import_mv90_data_yearly  ''' + @PathFileName + ''',''' + @tablename + ''', ''' 
					+ @job_name + ''', ''' + @process_id + ''',''' + @user_login_id + ''''
	
	ELSE IF @tablename = 'hourly_data'
	    SET @spa = 'spa_import_hourly_data  ''' + @PathFileName + ''',''' + @tablename + ''', ''' 
					+ @job_name + ''', ''' + @process_id + ''',''' + @user_login_id + ''''
	
	ELSE IF @tablename = 'ppa_data'
	    SET @spa = 'spa_import_ppa_data  ''' + @PathFileName + ''',''' + @tablename + ''', ''' 
					+ @job_name + ''', ''' + @process_id + ''',''' + @user_login_id + ''''
	
	ELSE IF @tablename = 'epa_data'
	    SET @spa = 'spa_import_epa_data  ''' + @PathFileName + ''',''' + @tablename + ''', ''' 
					+ @job_name + ''', ''' + @process_id + ''',''' + @user_login_id + ''''
	
	ELSE IF @tablename = 'activity_data'
	    SET @spa = 'spa_import_activity_data  ''' + @PathFileName + ''',''' + @tablename + ''', ''' 
					+ @job_name + ''', ''' + @process_id + ''',''' + @user_login_id + ''''
	
	ELSE IF @tablename = 'Activity_Data_New'
	    SET @spa = 'spa_import_activity_data_simplerlogic  ''' + @PathFileName + ''',''' + @tablename + ''', ''' 
					+ @job_name + ''', ''' + @process_id + ''',''' + @user_login_id + ''''
	
	ELSE IF @tablename = 'epa_allowance_data'
	    SET @spa = 'spa_import_epa_allowance_data  ''' + @PathFileName + ''',''' + @facility_ids + ''',' 
					+ CAST(@purge_data AS VARCHAR) + ',''' + @user_login_id + ''', ''' + @process_id + ''',''' + @job_name + ''''
	
	ELSE IF @tablename = 'source_deal_detail_trm'
	BEGIN
			SET @table_no = '4005'
			SET @spa = 'spa_import_data_job  ''' + @PathFileName + ''',''' + @table_no + ''', ''' 
						+ @job_name + ''', ''' + @process_id + ''',''' + @user_login_id + ''',''n'',12'
	END
	
	--called spa_import_data_source_deal_detail_trm to get all the required values of header and detail from the template 
	ELSE IF @tablename = 'source_deal_detail_trm_essent_excel' 
	BEGIN
		SET @table_no = '4005'
		SET @spa = 'spa_import_data_source_deal_detail_trm_essent_excel  ''' + @PathFileName + ''',''' + @table_no + ''', ''' 
					+ @job_name + ''', ''' + @process_id + ''',''' + @user_login_id + ''''
	END
	
	ELSE IF @tablename = 'source_deal_detail_essent'
	BEGIN
	    SET @table_no = '4005'
	    SET @spa = 'spa_import_data_job  ''' + @PathFileName + ''',''' + @table_no  + ''', ''' 
					+ @job_name + ''', ''' + @process_id + ''',''' + @user_login_id + ''',''n'',1'
	END
	
	ELSE IF @tablename = 'Deal_SNWA'
	BEGIN
	    SET @table_no = '4028'
	    SET @spa = 'spa_interface_Adaptor_SNWA  ''' + @PathFileName + ''',''' + @table_no + ''', ''' 
					+ @job_name + ''', ''' + @process_id + ''',''' + @user_login_id + ''''
	END
	
	ELSE IF @tablename = 'stage_generator'
	    SET @spa = 'spa_import_source_facility  ''' + @PathFileName + ''',''' + @tablename + ''', ''' 
					+ @job_name + ''', ''' + @process_id + ''',''' + @user_login_id + ''''
	
	ELSE IF @tablename = 'load_forecast'
	    SET @spa = 'spa_import_load_forecast  ''' + @PathFileName + ''',''' + @tablename + ''', ''' 
					+ @job_name + ''', ''' + @process_id + ''',''' + @user_login_id + ''''
	
	ELSE IF @tablename = 'rec_loadstar_mins'
	    SET @spa = 'spa_import_mv90_data_mins  ''' + @PathFileName + ''',''' + @tablename + ''', ''' 
					+ @job_name + ''', ''' + @process_id + ''',''' + @user_login_id + ''''
	
	ELSE IF @tablename = 'deal_detail_hour_lrs'
	    SET @spa = 'spa_import_deal_hourly_data  ''' + @PathFileName + ''', ''' 
					+ @job_name + ''', ''' + @process_id + ''',''' + @file_name + ''', 4035, ''' + @user_login_id + ''''
	
	ELSE IF @tablename = 'deal_detail_hour_csv'
	    SET @spa = 'spa_import_deal_hourly_data  ''' + @PathFileName + ''', ''' 
					+ @job_name + ''', ''' + @process_id + ''',''' + @file_name + ''', 4036, ''' + @user_login_id + ''''
	
	ELSE IF @tablename = 'source_deal_detail_hour'
	    SET @spa = 'spa_import_shaped_hourly_data  ''' + @PathFileName + ''', ''' 
					+ @job_name + ''', ''' + @process_id + ''',''' + @file_name + ''' , ''' + @user_login_id + ''''
	
	ELSE IF @tablename = 'RECs_Actual'
		SET @spa = 'spa_import_rec_actual  ''' + @PathFileName + ''',''' + @process_id + ''', ''' 
					+ @job_name + ''', ''' + @file_name + ''' , ''' + @user_login_id + ''''	
					
	ELSE IF @tablename = 'NCRETS_Retirement'
		SET @spa = 'spa_import_ncrets_retirement  ''' + @PathFileName + ''', ''' + @process_id + ''', ''' 
					+ @job_name + ''', ''' + @file_name + ''' , ''' + @user_login_id + ''''	
	
					
	ELSE IF @tablename = 'NCRETS'
		SET @spa = 'spa_import_ncrets  ''' + @PathFileName + ''', ''' + @process_id + ''', ''' 
					+ @job_name + ''', ''' + @file_name + ''' , ''' + @user_login_id + ''''					
					
	ELSE IF @tablename = 'mv90_data_mins'
	    SET @spa = 'spa_import_15_mins_data  ''' + @PathFileName + ''',''' + @tablename + ''', ''' 
					+ @job_name + ''', ''' + @process_id + ''',''' + @user_login_id + ''''
	
	ELSE IF @tablename = 'holiday_group'
	    SET @spa = 'spa_import_expiration_calendar  ''' + @PathFileName + ''',''' + @tablename + ''', ''' 
					+ @job_name + ''', ''' + @process_id + ''',''' + @user_login_id + ''''
	
	ELSE IF @tablename = 'imbalance_volume'
	BEGIN
		SET @spa = 'spa_import_imbalance_volume  ''' + @PathFileName + ''',''' + @tablename + ''', '''
					+ @job_name + ''', ''' + @process_id + ''',''' + @user_login_id + ''''
	END
	ELSE IF @tablename = 'WREGIS_Import'
	    SET @spa = 'spa_import_wregis_upload  ''' + @PathFileName + ''',''' + @process_id + ''', ''' 
					+ @job_name + ''', ''' + @file_name + ''',''' + @user_login_id + ''''
		
	ELSE
	    SET @spa = 'spa_import_data_job  ''' + @PathFileName + ''',''' + @table_no + ''', ''' 
					+ @job_name + ''', ''' + @process_id + ''',''' + @user_login_id + ''''
		
	EXEC spa_print @spa
	
	INSERT import_data_files_audit
	  (
	    dir_path,
	    imp_file_name,
	    as_of_date,
	    STATUS,
	    elapsed_time,
	    process_id,
	    create_user,
	    create_ts
	  )
	VALUES
	  (
	    'File import:' + @tablename,
	    'Data upload (Table No.:' + @table_no + ')',
	    GETDATE(),
	    's',
	    0,
	    @process_id,
	    @user_login_id,
	    GETDATE()
	  )
	  
	EXEC spa_print 'inserted import_data_files_audit'
	
	EXEC spa_run_sp_as_job @job_name,  @spa, 'ImportData', @user_login_id
	
	EXEC spa_ErrorHandler 0,
	     'ImportData',
	     'process run',
	     'Status',
	     'Import process has been run and will complete shortly.',
	     'Please Check/Refresh your message board.'
