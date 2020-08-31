IF OBJECT_ID('spa_RDB_ad_hoc_interface_job') IS NOT NULL
	DROP  PROCEDURE [dbo].[spa_RDB_ad_hoc_interface_job] 
GO

--select * from source_system_data_import_status where process_id='88881'
-- No data found in staging table(source_deal_detail).
--spa_SSIS_ad_hoc_interface_job 'n','sss','2'

CREATE proc [dbo].[spa_RDB_ad_hoc_interface_job] 
	@process_ssis char(1)=NULL,
	@process_id varchar(150),
	@source_system varchar(150)=null,
	@run_as_of_date varchar(20)=null,
	@is_incremental varchar(1)=NULL,
	@user_login_id VARCHAR(50) = 'farrms_admin'
AS
	--declare @user_login_id varchar(50)
	declare @source_name varchar(100),@spa varchar(500),
	@is_incremental_int int,@job_name varchar(200)

	--set @user_login_id=dbo.FNADBUser()

	declare @desc varchar(500)

	if @process_ssis='y'
	BEGIN
		BEGIN TRY
			set @desc='FASTracker RDB process started, please visit Import Audit Report for detail status '
			EXEC  spa_message_board 'u', @user_login_id, NULL, 'ImportData',  @desc, '', '', 's', @process_id,
			null,@process_id,NULL,'n',NULL,'y' 
			IF @is_incremental IS NULL OR @is_incremental='n' 
				SET @is_incremental_int=0
			ELSE
				SET @is_incremental_int=1

			--SET @job_name = 'importdata_rdb_'+ @process_id
			SET @job_name = 'importdata_'+ @process_id

			SET @spa = 'spa_import_data_from_rdb  ''' + @run_as_of_date  +''',' + cast(@is_incremental_int AS varchar)  +  ''
			exec spa_print @spa

			--create job again to support queue processing
			EXEC spa_run_sp_as_job @job_name, @spa, 'ImportData', @user_login_id, 'TSQL',@source_system,'y'
			--EXEC(@spa)
		end try
		begin catch
			
			set @desc='SQL Error found:  (' + ERROR_MESSAGE() + ')'
			
			insert into source_system_data_import_status(process_id,code,module,source,type,
			[description],recommendation) 
			select @process_id,'Error','ImportData','Interface',
			'Data Error',
			@desc,'N/A.'
			
			EXEC  spa_message_board 'u', @user_login_id, NULL, 'ImportData',  @desc, '', '', 'e', @process_id,
			null,@process_id,NULL,'n',NULL,'y' 	
		end catch
	END
	ELSE
	BEGIN
		DECLARE @start_ts		datetime
		DECLARE @elapsed_time	float

		SET @start_ts = GETDATE()
		BEGIN TRY
			set @desc='FASTracker Interface process from staging table started, please visit Import Audit Report for detail status '
			EXEC  spa_message_board 'u', @user_login_id, NULL, 'ImportData',  @desc, '', '', 's', @process_id,
			null,@process_id,NULL,'n',NULL,'y' 

			select @source_name=source_system_name from source_system_description where source_system_id=@source_system

			insert import_data_files_audit(dir_path,
					imp_file_name,
					as_of_date,
					status,
					elapsed_time,
					process_id,
					create_user,
					create_ts,
					source_system_id)
			values('Adhoc Interface',
					'Process from staging tables',
					convert(varchar,getdate(),102),
					'p',
					0,
					@process_id,
					@user_login_id,
					getdate(),
					@source_system)

			SET @job_name = 'importdata_staging_'+ @process_id

			SET @spa = 'spa_import_data_from_staging  ''' + @process_id  + ''', ''' + @source_name  +  ''''
			exec spa_print @spa

			--create job again to support queue processing
			EXEC spa_run_sp_as_job @job_name, @spa, 'ImportData', @user_login_id, 'TSQL',@source_system,'y'

		END TRY
		BEGIN CATCH
			
			SET @desc = 'SQL Error found:  (' + ERROR_MESSAGE() + ')'
			SET @elapsed_time = DATEDIFF(second, @start_ts, GETDATE())
			
			INSERT INTO source_system_data_import_status(process_id,code,module,source,[type],
			[description],recommendation) 
			SELECT @process_id, 'Error', 'Import Data', 'Interface', 'Data Error', @desc,'N/A.'

			UPDATE import_data_files_audit
			SET status = 'e', elapsed_time = @elapsed_time
			WHERE process_id = @process_id
			
			EXEC  spa_message_board 'u', @user_login_id, NULL, 'ImportData',  @desc, '', '', 'e', @process_id,
			null,@process_id,NULL,'n',NULL,'y' 	
		END CATCH

		--if (select count(*) from ssis_position_formate2_error_log) > 0
		--begin
		--	exec sp_ssis_position_formate2 @process_id,NULL,NULL,'y'
		--end
		--if (select count(*) from ssis_position_formate1_error_log) > 0
		--begin
		--	exec sp_ssis_position_formate1 @process_id,NULL,NULL,'y'
		--end
	END


GO
