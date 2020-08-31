IF OBJECT_ID('spa_interface_Adaptor_job') IS NOT NULL
	DROP  PROCEDURE [dbo].[spa_interface_Adaptor_job]
GO
CREATE PROCEDURE [dbo].[spa_interface_Adaptor_job]
	@import_data_type VARCHAR(150) = NULL,
	@books VARCHAR(500) = NULL,
	@frm_date_imp VARCHAR(20) = NULL,
	@to_date_imp VARCHAR(20) = NULL,
	@user_login_id VARCHAR(50) = NULL,
	@system_id VARCHAR(10) = '2',
	@filter_deals VARCHAR(8000) = NULL,
	@log_check VARCHAR(1) = 'y',  --y: repopulate staging table; n: import from staging table without repopulating
	@bulk_import VARCHAR(1) = 'n', --new change for eneco (in case of Essent, it is is_incremental)
	@import_from VARCHAR(100) = NULL,
	@client_name    VARCHAR(100) =NULL,
	@batch_process_id VARCHAR(50) = NULL,	
	@batch_report_param VARCHAR(1000) = NULL
AS
	--DECLARE @client_name    VARCHAR(100)
	DECLARE @spa            VARCHAR(MAX)
	DECLARE @job_name       VARCHAR(256)
	DECLARE @process_id     VARCHAR(128)
	DECLARE @par            VARCHAR(1000),
	        @min            AS INT,
	        @proc_desc      VARCHAR(50)
	
	DECLARE @time_diff_min  INT,
	        @start_time     DATETIME
	
	DECLARE @msg            VARCHAR(200)
	DECLARE @ssis_path      VARCHAR(5000),
	        @root           VARCHAR(1000)
	DECLARE @complete_time  VARCHAR(50),
		        @as_of_date     DATETIME,
		        @desc           VARCHAR(300)

	SELECT @client_name = db_serverName
	FROM   connection_string
	
	SET @as_of_date = GETDATE()

	IF @batch_process_id IS NOT NULL
	    SET @process_id = @batch_process_id
	ELSE
	    SET @process_id = REPLACE(NEWID(), '-', '_')
	
	SELECT @user_login_id = ISNULL(@user_login_id, dbo.FNADBUser())
	
	IF @client_name = 'Eneco'
	BEGIN
	    SET @time_diff_min = 0 --time difference between zainet and fastracker database server location
	    SET @proc_desc = 'Interface'
	    
	    SET @job_name = @proc_desc + '_' + @process_id
	    SET @start_time = DATEADD(mi, @time_diff_min -3, GETDATE())
	    IF @bulk_import = 'y'
	        SELECT @min = setting_value
	        FROM   farrms_config_setting
	        WHERE  source_system_id = @system_id
	               AND setting_id = (@import_data_type * 10) + 1 --adding 1 in @import_data_type as prefix
	    IF @min IS NULL
	        SELECT @min = setting_value
	        FROM   farrms_config_setting
	        WHERE  source_system_id = @system_id
	               AND setting_id = @import_data_type
	    --add new line
	    SET @log_check = ISNULL(@log_check, 'y')
	        --if @log_check='y'

			IF ISNULL(@log_check, 'y') = 'y' --change
			BEGIN
			    IF @min IS NULL
			        SET @min = 1
			    ELSE
			        SET @min = ROUND(@min / 60, 0) --convert second into minute
			END
			ELSE
			BEGIN
			    SET @min = 0--1
			END
			--if @system_id=2  --zainet

			IF @system_id = '2' --zainet
			BEGIN
			    SET @par = ' ''' + @import_data_type + ''''
			    --If @books IS NULL 
			    IF ISNULL(@books, 'null') = 'null'
			        SET @par = @par + ',null'
			    ELSE
			        SET @par = @par + ',''' + @books + ''''
			    --If @frm_date_imp IS NULL 
			    IF ISNULL(@frm_date_imp, 'null') = 'null'
			        SET @par = @par + ',null'
			    ELSE
			        SET @par = @par + ',''' + @frm_date_imp + ''''
			    
			    SET @par = @par + ',''' + @user_login_id + ''''
			    SET @par = @par + ',''' + CAST(@system_id AS VARCHAR) + ''''
			    SET @par = @par + ',''n'''
			    SET @par = @par + ',''' + @process_id + ''''
			    --if @filter_deals is null
			    IF ISNULL(@filter_deals, 'null') = 'null'
			        SET @par = @par + ',null'
			    ELSE
			        SET @par = @par + ',''' + @filter_deals + ''''
			    
			    SET @par = @par + ',''' + CAST(@start_time AS VARCHAR) + ''''
			    SET @par = @par + ',''' + @log_check + ''''
			    SET @par = @par + ',''' + @bulk_import + ''''
			END

			SET @spa = 'spa_interface_Adaptor_' + @system_id + @par
			EXEC spa_print @spa
			EXEC spa_run_sp_as_job_schedule @job_name,
			     @spa,
			     @proc_desc,
			     @user_login_id,
			     @min
			
				
			SET @complete_time = DATEADD(mi, @min, GETDATE())

			insert into source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
			select @process_id,'Info','Import Data','Schedule_log','Log Info','See Zai*Net Log for 3 days.','Zai*net Log.'
			insert into source_system_data_import_status_detail(process_id,source,
			type,[description],create_ts) 
			select @process_id,'Schedule_log','Info','See Zai*Net Log for 3 days.',getdate()

			SET @desc = 
			    'Your Ad-hoc import data process has been run and will complete by: ' 
			    + @complete_time
			
			EXEC spa_message_board 'i',
			     @user_login_id,
			     NULL,
			     @proc_desc,
			     @desc,
			     '',
			     '',
			     's',
			     NULL,
			     @as_of_date,
			     @process_id
			
			EXEC spa_ErrorHandler 0,
			     'ImportData',
			     'Process run',
			     'Status',
			     'Your Ad-hoc import data process has been run and will complete shortly.',
			     'Please check/refresh your message board.'
			RETURN
	END
	ELSE IF @client_name = 'Essent'
	BEGIN
			-- Used for Essent
			DECLARE @is_incremental VARCHAR(1)
			SET @is_incremental = ISNULL(@bulk_import, 'n')
			
			
			IF @import_data_type = 4064 -- Pipeline Cut Import
			BEGIN
				
				IF  NOT EXISTS(SELECT 1 FROM import_data_files_audit WHERE process_id = @process_id)
				BEGIN
					EXEC spa_import_data_files_audit 'i',@as_of_date,NULL,@process_id, 'Pipeline Cut Import','pipeline_cut_import',@as_of_date,'p',NULL,@as_of_date,NULL,@system_id
				END
				
				SELECT @root = dbo.FNAGetSSISPkgFullPath('PRJ_PipelineCut', 'User::PS_PackageSubDir')
				SET @ssis_path = @root + 'pipeline_cut_import.dtsx'
				SET @spa = N'/FILE "' + @ssis_path + '" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E  /SET "\Package.Variables[User::PS_ProcessID].Properties[Value]";"' + @process_id + '" /SET "\Package.Connections[OLE_CONN_MainDB].Properties[UserName]";"' + @user_login_id + '" /SET "\Package.Variables[User::PS_UserName].Properties[Value]";"' + @user_login_id + '"'			
				--SET @proc_desc='importdata_SSIS_RWE'
				SET @proc_desc = 'importdata_pipelinecut'
				SET @job_name = @proc_desc + '_' + @process_id

				EXEC dbo.spa_run_sp_as_job @job_name, @spa, 'SSIS_pipeline', @user_login_id, 'SSIS', @system_id, 'y'

				RETURN
			END

			IF @import_data_type = 4035 --deal detail hour
			BEGIN
				DECLARE @import_type INT
				SELECT @import_type = CASE @is_incremental WHEN 'n' THEN 2 ELSE 1 END


				IF  NOT EXISTS(SELECT 1 FROM import_data_files_audit WHERE process_id = @process_id)
				BEGIN
					EXEC spa_import_data_files_audit 'i',@as_of_date,NULL,@process_id, 'Import Deal Hourly Data','deal_detail_hour',@as_of_date,'p',NULL,@as_of_date,NULL,@system_id
				END
				
				--IF ISNULL(@log_check, 'n') = 'n'
				--	EXEC dbo.spa_generate_position_breakdown_data @import_type, 'deal_detail_hour', @user_login_id, @process_id, 'n'
				--ELSE
				--	EXEC dbo.spa_generate_job_import_deal_detail_hour @import_type, 'deal_detail_hour', @user_login_id
				
				SELECT @root = dbo.FNAGetSSISPkgFullPath('PRJ_LoadForecastDataImportIS', 'User::PS_PackageSubDir')

				SET @ssis_path = @root + 'LoadForecastDataParse.dtsx'
				SET @spa = N'/FILE "' + @ssis_path + '" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET "\Package.Variables[User::PS_ProcessID].Properties[Value]";"' + @process_id + '" /SET "\Package.Connections[OLE_CONN_MainDB].Properties[UserName]";"' + @user_login_id+ '"'
			
				SET @proc_desc = 'import_load_forecastdata'
				SET @job_name = @proc_desc + '_' + @process_id

				EXEC dbo.spa_run_sp_as_job @job_name, @spa, 'SSIS_Load_Forecast', @user_login_id, 'SSIS', @system_id, 'y'
				
				RETURN
			END
			
			
			IF @import_data_type = 4041 -- pratos
			BEGIN
				SET @proc_desc = 'import_pratos'
				SET @job_name = @proc_desc + '_' + @process_id
				SET @spa = 'spa_soap_pratos NULL,NULL,NULL,''y'''
				
				--EXEC spa_soap_pratos NULL,NULL,NULL,'y'
				EXEC dbo.spa_run_sp_as_job @job_name, @spa, 'PRATOS_Import', @user_login_id, 'TSQL', @system_id, 'y'
				RETURN 
			END
			

			--SELECT @root = dbo.FNAGetSSISPkgFullPath('PRJ_CMAInterface', 'User::PS_PackageSubDir')
			
			
			IF @import_data_type = 4043 -- eBase
			BEGIN
				
				IF  NOT EXISTS(SELECT 1 FROM import_data_files_audit WHERE process_id = @process_id)
				BEGIN
					EXEC spa_import_data_files_audit 'i',@as_of_date,NULL,@process_id, 'Import Ebase Meter Data','ebase_meter_data',@as_of_date,'p',NULL,@as_of_date,NULL,@system_id
				END
				
				SELECT @root = dbo.FNAGetSSISPkgFullPath('PRJ_eBaseMeterDataImport', 'User::PS_PackageSubDir')
				SET @ssis_path = @root + 'eBaseMeterDataImport.dtsx'
				SET @spa = N'/FILE "' + @ssis_path + '" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E  /SET "\Package.Variables[User::PS_ProcessID].Properties[Value]";"' + @process_id + '" /SET "\Package.Connections[OLE_CONN_MainDB].Properties[UserName]";"' + @user_login_id+ '"'				
				--SET @proc_desc='importdata_SSIS_RWE'
				SET @proc_desc = 'import_ebase_data'
				SET @job_name = @proc_desc + '_' + @process_id

				EXEC dbo.spa_run_sp_as_job @job_name, @spa, 'SSIS_eBase', @user_login_id, 'SSIS', @system_id, 'y'

				RETURN
			END
			
			IF @import_data_type = 4047 -- Short Term Forecast
			BEGIN
				
				IF  NOT EXISTS(SELECT 1 FROM import_data_files_audit WHERE process_id = @process_id)
				BEGIN
					EXEC spa_import_data_files_audit 'i', @as_of_date, NULL, @process_id, 'Short Term Forecast Data', 'Short Term Forecast Import', @as_of_date, 'p', NULL, @as_of_date, NULL, @system_id
				END

				SELECT @root = dbo.FNAGetSSISPkgFullPath('PRJ_shortTermForecastImport', 'User::PS_PackageSubDir')
				SET @ssis_path = @root + 'ShortTermForecast.dtsx'
				SET @spa = N'/FILE "' + @ssis_path + '" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E  /SET "\Package.Variables[User::PS_ProcessID].Properties[Value]";"' + @process_id + '" /SET "\Package.Connections[OLE_CONN_MainDB].Properties[UserName]";"' + @user_login_id+ '"'				
				--SET @proc_desc='importdata_SSIS_RWE'
				SET @proc_desc = 'importdata_short_term'
				SET @job_name = @proc_desc + '_' + @process_id

				EXEC dbo.spa_run_sp_as_job @job_name, @spa, 'SSIS_short_term', @user_login_id, 'SSIS', @system_id, 'y'

				RETURN
			END
						
      
			/* CMA PRICE CURVE 
			* Different import data type casing is done for cma price curve REQUEST and RESPONSE so as to handle job from front end 
			* but PS_TableCode (module_type) is 4008 for both request and response 
			*/
			
			SELECT @root = dbo.FNAGetSSISPkgFullPath('PRJ_CMAInterface', 'User::PS_PackageSubDir')
			
			IF @import_data_type = 4038 -- cma price curve request
			BEGIN
				
				SET @ssis_path = @root + 'RequestPackage.dtsx'
				SET @spa = N'/FILE "' + @ssis_path + '" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E  /SET "\Package.Variables[User::PS_ProcessId].Properties[Value]";"' + @process_id + '"  /SET "\Package.Variables[User::PS_AsOfDate].Properties[Value]";"' + @to_date_imp + '" /SET "\Package.Connections[OLE_CONN_MainDB].Properties[UserName]";"' + @user_login_id+ '"'				
				--SET @proc_desc='importdata_SSIS_RWE'
				SET @proc_desc = 'import_cma_data'
				SET @job_name = @proc_desc + '_' + @process_id

				EXEC dbo.spa_run_sp_as_job @job_name, @spa, 'SSIS_CMA_Request', @user_login_id, 'SSIS', @system_id, 'y'

				RETURN
			END
			
			IF @import_data_type = 4039 -- cma price curve response
			BEGIN
				SET @ssis_path = @root + 'ResponsePackage.dtsx'
				SET @spa = N'/FILE "' + @ssis_path + '" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET "\Package.Variables[User::PS_ProcessId].Properties[Value]";"' + @process_id + '" /SET "\Package.Connections[OLE_CONN_MainDB].Properties[UserName]";"' + @user_login_id+ '"'

				--Audit table log
				IF NOT EXISTS(SELECT 1 FROM import_data_files_audit WHERE process_id=@process_id)
					EXEC spa_import_data_files_audit 'i', @as_of_date, NULL, @process_id, 'Import CMA Data', 
						 'CMA Data upload (Table No.:4008)', @as_of_date, 'p', NULL, NULL, NULL, @system_id


				--SET @proc_desc='importdata_SSIS_RWE'
				SET @proc_desc = 'import_cma_data'
				SET @job_name = @proc_desc + '_' + @process_id

				EXEC dbo.spa_run_sp_as_job @job_name, @spa, 'SSIS_CMA_response', @user_login_id, 'SSIS', @system_id, 'y'
				
				RETURN
			END
			
			IF @import_data_type = 4040 -- TRAYPORT TERM MAPPING
			BEGIN
				
				SET @proc_desc = 'import_trayport_data'
				SET @job_name = @proc_desc + '_' + @process_id
				SET @spa = 'spa_trayport_staging_process '''+@process_id+''',''y'''
				
				--PRINT @spa
				--SELECT @job_name, @spa, 'spa_trayport_staging_process', @user_login_id, 'Trayport', @system_id, 'y'
				EXEC dbo.spa_run_sp_as_job @job_name, @spa, 'spa_trayport_staging_process', @user_login_id, 'TSQL', @system_id, 'y'
				
				RETURN 
			END
			IF @import_data_type = 4046 --Nomination import (Shaped deal, table: source_deal_detail_hour)
			BEGIN
				
				IF  NOT EXISTS (SELECT 1 FROM import_data_files_audit WHERE process_id = @process_id)
				BEGIN
					EXEC spa_import_data_files_audit 'i', @as_of_date, NULL, @process_id, 'Shaped Hourly Data Import', 'source_deal_detail_hour', @as_of_date, 'p', NULL, @as_of_date, NULL, @system_id
				END
				
				SELECT @root = dbo.FNAGetSSISPkgFullPath('PKG_ShapedHourlyDealImport', 'User::PS_PackageSubDir') 

				SET @ssis_path = @root + 'ShapedHourlyDealImport.dtsx'
				SET @spa = N'/FILE "' + @ssis_path + '" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET "\Package.Variables[User::PS_ProcessID].Properties[Value]";"' + @process_id + '" /SET "\Package.Connections[OLE_CONN_MainDB].Properties[UserName]";"' + @user_login_id+ '"'
				
				--SET @proc_desc='importdata_SSIS_RWE'
				SET @proc_desc = 'import_shaped_hourly_data'
				SET @job_name = @proc_desc + '_' + @process_id
				
				 EXEC dbo.spa_run_sp_as_job @job_name, @spa, 'SSIS_ShapedHourlyData_Import', @user_login_id, 'SSIS', @system_id, 'y'
				  
				RETURN
			END

                        IF @import_data_type = 4049 --PriceCurveVolatilityCorrelation Import
			BEGIN
				
				IF  NOT EXISTS (SELECT 1 FROM import_data_files_audit WHERE process_id = @process_id)
				BEGIN
					EXEC spa_import_data_files_audit 'i', @as_of_date, NULL, @process_id, 'PriceCurveVolatilityCorrelation Data Import', 'source_price_curve,curve_correlation,curve_volatility', @as_of_date, 'p', NULL, @as_of_date, NULL, @system_id
				END
				
				SELECT @root = dbo.FNAGetSSISPkgFullPath('PKG_PriceCurveVolatilityCorrelationDataImport', 'User::PS_PackageSubDir') 

				SET @ssis_path = @root + 'PriceCurveVolatilityCorrelationImport.dtsx'
				SET @spa = N'/FILE "' + @ssis_path + '" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET "\Package.Variables[User::PS_ProcessID].Properties[Value]";"' + @process_id + '" /SET "\Package.Connections[OLE_CONN_MainDB].Properties[UserName]";"' + @user_login_id+ '"'
				
				--SET @proc_desc='importdata_SSIS_RWE'
				SET @proc_desc = 'importdata_pricecurve_volatility_correlation_data'
				SET @job_name = @proc_desc + '_' + @process_id
				
				 EXEC dbo.spa_run_sp_as_job @job_name, @spa, 'SSIS_PriceCurveVolatilityCorrelationData_Import', @user_login_id, 'SSIS', @system_id, 'y'
				  
				RETURN
			END

			IF @import_data_type = 4048--IceDeal Import
			BEGIN
				
				--IF  NOT EXISTS (SELECT 1 FROM import_data_files_audit WHERE process_id = @process_id)
				--BEGIN
				--	EXEC spa_import_data_files_audit 'i', @as_of_date, NULL, @process_id, 'Shaped Hourly Data Import', 'source_deal_detail_hour', @as_of_date, 'p', NULL, @as_of_date, NULL, @system_id
				--END
				
				SELECT @root = dbo.FNAGetSSISPkgFullPath('PKG_ICEDeal', 'User::PS_PackageSubDir') 

				SET @ssis_path = @root + 'IceDealImport.dtsx'
				SET @spa = N'/FILE "' + @ssis_path + '" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET "\Package.Variables[User::PS_ProcessID].Properties[Value]";"' + @process_id + '" /SET "\Package.Connections[OLE_CONN_MainDB].Properties[UserName]";"' + @user_login_id+ '"'
				
				--SET @proc_desc='importdata_SSIS_RWE'
				SET @proc_desc = 'importdata_ice_deal_data'
				SET @job_name = @proc_desc + '_' + @process_id
				
				 EXEC dbo.spa_run_sp_as_job @job_name, @spa, 'SSIS_ICEDealData_Import', @user_login_id, 'SSIS', @system_id, 'y'
				  
				RETURN
			END
			IF @import_data_type = 4042 -- RDB Export
                  BEGIN
                        
                        SELECT @root = dbo.FNAGetSSISPkgFullPath('PRJ_RDBInterface', 'User::PS_PackageSubDir')
                        SET @ssis_path = @root + 'RDB_Package.dtsx'
                        SET @spa = N'/FILE "' + @ssis_path + '" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET "\Package.Variables[User::PS_ProcessId].Properties[Value]";"' + @process_id + '" /SET "\Package.Connections[OLE_CONN_MainDB].Properties[UserName]";"' + @user_login_id+ '"'
                              
                        --SET @proc_desc='importdata_SSIS_RWE'
                        SET @proc_desc = 'export_rdb_data'
                        SET @job_name = @proc_desc + '_' + @process_id
 
                        EXEC dbo.spa_run_sp_as_job @job_name, @spa, 'SSIS_RDB', @user_login_id, 'SSIS', @system_id, 'y'
                        
                        RETURN 
                  END
			IF @import_data_type = 4045 --nominator_job
			BEGIN
				SELECT @root = dbo.FNAGetSSISPkgFullPath('PKG_LoadForecastNominatorRequest', 'User::PS_PackageSubDir')
				SET @ssis_path = @root + 'LoadForecastNominatorRequest.dtsx'
				-- nominator request processID is extracted as from pratos deals
				SET @spa = N'/FILE "' + @ssis_path + '" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET "\Package.Variables[User::PS_AsOfDate].Properties[Value]";"' + CONVERT(VARCHAR(10),@as_of_date, 120) + '" /SET "\Package.Connections[OLE_CONN_MainDB].Properties[UserName]";"' + @user_login_id+ '"'
				SET @proc_desc = 'nominator_request_load_forecastdata'
				SET @job_name = @proc_desc + '_' + @process_id

				EXEC dbo.spa_run_sp_as_job @job_name, @spa, 'SSIS_Load_Forecast', @user_login_id, 'SSIS', @system_id, 'y'
				
				RETURN	
			END
			
			IF @import_data_type = 4044 --trayport_job
			BEGIN
				SELECT @root = dbo.FNAGetSSISPkgFullPath('PKG_Trayport', 'User::PS_PackageSubDir')
				SET @ssis_path = @root + 'TrayPortImport.dtsx'
				SET @spa = N'/FILE "' + @ssis_path + '" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E '
				SET @proc_desc = 'trayport_import'
				SET @job_name = @proc_desc + '_' + @process_id

				EXEC dbo.spa_run_sp_as_job @job_name, @spa, 'SSIS_trayport', @user_login_id, 'SSIS', @system_id, 'y'
				
				RETURN	
			END                     
						 
			IF @import_data_type = 4061--Platts Import
			BEGIN
				DECLARE 	@folder			VARCHAR(500)	,			
							@year			VARCHAR(4)		,
							@month			VARCHAR(2)		,
							@day			VARCHAR(2)	,
							@dateFrom		DATETIME  = NULL
							
				SELECT @root = dbo.FNAGetSSISPkgFullPath('PKG_PlattsPriceCurveImport', 'User::PS_PackageSubDir') 

				SET @ssis_path = @root + 'platts.dtsx'
				--PRINT @ssis_path
				
				IF	@import_from = 'p'				
					SELECT @folder = 'postclose'
				ELSE IF	@import_from = 't'				
					SELECT @folder = 'today'				
				ELSE IF @import_from IN ('d','y','k')
				BEGIN							
					SELECT @dateFrom = CASE WHEN @import_from IN ('y','k') THEN dbo.FNAPlattsDate(@import_from) ELSE @dateFrom END

					SELECT @year	= YEAR(@dateFrom),
						   @month   = MONTH(@dateFrom), 
						   @day		= DAY(@dateFrom)

					SELECT @month	= CASE WHEN CAST(@month AS INT) < 10 THEN '0'+ @month ELSE @month END,
						   @day		= CASE WHEN CAST(@day AS INT) < 10 THEN '0'+ @day ELSE @day END	
					
					SELECT @folder = @year+@month+@day
				END
					SELECT @folder = '/' + @folder + '/*.*'

				--SELECT @ssis_path, @user_login_id, @folder
				
				SET @spa = N'/FILE "' + @ssis_path + '" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E  /SET "\Package.Connections[OLE_CONN_MainDB].Properties[UserName]";"' + @user_login_id + '" /SET "\Package.Variables[User::PS_UserLoginID].Properties[Value]";"' + @user_login_id + '" /SET "\Package.Variables[User::ps_setupFileName].Properties[Value]";"platts"'+ ' /SET "\Package.Variables[User::ps_ftpLocForPriceCurves].Properties[Value]";"' + @folder+ '"'
				SET @proc_desc = 'importdata_platts'
				SET @job_name = @proc_desc + '_' + @process_id
				
				EXEC spa_print @spa
				 EXEC dbo.spa_run_sp_as_job @job_name, @spa, 'SSIS_PlattsPricecurveData_Import', @user_login_id, 'SSIS', @system_id, 'y'
				  
				RETURN
			END                   
				
			/*			 
			IF @system_id = '3' --RWE Endur
			BEGIN
			
				SELECT @root =  import_path  FROM connection_string
				SELECT @ssis_path = @root + '\rwe.dtsx'

				--set @spa=N'/FILE "'+@ssis_path+'" /CONFIGFILE "'+@root+'\config.dtsConfig" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET \Package.Variables[User::ps_workspace].Properties[Value];"'+@root+'" /SET \Package.Connections[Staging_Table_Insertion].Properties[UserName];"'+ @user_login_id+ '" /SET \Package.Connections[Staging_Table_Insertion].Properties[Password];"Admin2929" /SET \Package.Variables[User::ps_batchCreatedDateTime].Properties[Value];"'+  convert(varchar(20),getdate(),120) +'"'

				--set @spa=N'/FILE "'+@ssis_path+'" /CONFIGFILE "'+@root+'\config.dtsConfig" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET \Package.Variables[User::ps_workspace].Properties[Value];"'+@root+'" /SET \Package.Connections[Staging_Table_Insertion].Properties[UserName];"'+ @user_login_id+ '" /SET \Package.Variables[User::ps_batchCreatedDateTime].Properties[Value];"'+  convert(varchar(20),getdate(),120) +'"'
				
				set @spa=N'/FILE "'+@ssis_path+'" /CONFIGFILE "'+@root+'\config.dtsConfig" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET \Package.Connections[Staging_Table_Insertion].Properties[UserName];"'+ @user_login_id+ '" /SET \Package.Variables[User::ps_batchCreatedDateTime].Properties[Value];"'+  convert(varchar(20),getdate(),120) +'"'
				
				--SET @proc_desc='importdata_SSIS_RWE'
				SET @proc_desc='importdata'
				SET @job_name = @proc_desc+'_' + @process_id

				EXEC dbo.spa_run_sp_as_job @job_name,@spa,'SSIS_RWE_Deal',@user_login_id,'SSIS',@system_id,'y'

			---	exec spa_run_Import_package 'r','re'
				RETURN
			END


			ELSE IF @system_id = '20' --RWE DE Endur
			BEGIN
				DECLARE @ssispath VARCHAR(5000)
				DECLARE @package_source TINYINT
				SET @package_source = 1 -- 1:filesystem, 2:msdb
				
				DECLARE @package_name VARCHAR(128), @database VARCHAR(128)
				SET @package_name = 'EndurDataImport'
				SELECT @database = DB_NAME()
				
                SET @proc_desc = 'endur_import_data'
                SET @job_name = @proc_desc + '_' + @process_id
				
				
				IF @package_source = 1 -- Uses filesystem source for package execution
				BEGIN
					SELECT @root = dbo.FNAGetSSISPkgFullPath('PKG_EndurDataImport', 'User::PS_PackageSubDir')
	                SET @ssispath = @root + @package_name + '.dtsx'

					SET @spa = N'/FILE "' + @ssispath + '" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET "\Package.Connections[OLE_CONN_MainDB].Properties[UserName]";"' + @user_login_id + '" /SET "\Package.Variables[User::PS_ProcessID].Properties[Value]";"' + @process_id + '" /SET "\Package.Variables[User::PS_UserName].Properties[Value]";"' + @user_login_id + '"'
				END
				
				IF @package_source = 2 -- Uses direct package execution via msdb
				BEGIN
					SET @package_name = '\' + @database + '\' + @package_name

					SET @spa = N'/SQL "' + @package_name + '" /SERVER "' + @@SERVERNAME + '" /CHECKPOINTING OFF /REPORTING E /SET "\Package.Variables[User::PS_ProcessID].Properties[Value]";"' + @process_id + '" /SET "\Package.Variables[User::PS_UserName].Properties[Value]";"' + @user_login_id + '"'
				END
				
				EXEC dbo.spa_run_sp_as_job @job_name, @spa, 'SSIS_RWE_DE_Endur', @user_login_id, 'SSIS', @system_id, 'y'

				
				----if windows auth & msdb
                --SET @spa = N'/SQL "' + @package_name + '" /SERVER "' + @@SERVERNAME + '" /CHECKPOINTING OFF /REPORTING E /SET "\Package.Variables[User::PS_ProcessID].Properties[Value]";"' + @process_id + '" /SET "\Package.Variables[User::PS_UserName].Properties[Value]";"' + @user_login_id + '"'

				-- if windows auth
                --SET @spa = N'/FILE "' + @ssispath + '" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET "\Package.Variables[User::PS_BatchCreatedDateTime].Properties[Value]";"' +
                -- CONVERT(VARCHAR(20), GETDATE(), 120) + '" /SET "\Package.Variables[User::PS_ProcessID].Properties[Value]";"' + @process_id + '"'

				                
        		RETURN
			END
			*/
			SET @job_name = 'importdata_rdb_adhoc_'+ @process_id
			SET @msg = 'FasTracker RDB process started, please visit Import Audit Report for detail status'
			EXEC spa_rdb_ad_hoc_interface_job  @log_check, @process_id, @system_id, @frm_date_imp, @is_incremental, @user_login_id
	END
	ELSE IF @client_name = 'RWEDE'
	BEGIN
		DECLARE @ssispath VARCHAR(5000)
		DECLARE @package_source TINYINT
		SET @package_source = 1 -- 1:filesystem, 2:msdb
				
		DECLARE @package_name VARCHAR(128), @database VARCHAR(128)
		SET @package_name = 'EndurDataImport'
		SELECT @database = DB_NAME()
				
        SET @proc_desc = 'endur_import_data'
        SET @job_name = @proc_desc + '_' + @process_id
				
				
		IF @package_source = 1 -- Uses filesystem source for package execution
		BEGIN
			SELECT @root = dbo.FNAGetSSISPkgFullPath('PKG_EndurDataImport', 'User::PS_PackageSubDir') + 'EndurDataImport\Packages\'
	        SET @ssispath = @root + @package_name + '.dtsx'

			SET @spa = N'/FILE "' + @ssispath + '" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET "\Package.Connections[OLE_CONN_MainDB].Properties[UserName]";"' + @user_login_id + '" /SET "\Package.Variables[User::PS_ProcessID].Properties[Value]";"' + @process_id + '" /SET "\Package.Variables[User::PS_UserName].Properties[Value]";"' + @user_login_id + '"'
		END
				
		IF @package_source = 2 -- Uses direct package execution via msdb
		BEGIN
			SET @package_name = '\' + @database + '\' + @package_name

			SET @spa = N'/SQL "' + @package_name + '" /SERVER "' + @@SERVERNAME + '" /CHECKPOINTING OFF /REPORTING E /SET "\Package.Variables[User::PS_ProcessID].Properties[Value]";"' + @process_id + '" /SET "\Package.Variables[User::PS_UserName].Properties[Value]";"' + @user_login_id + '"'
		END
				
		EXEC dbo.spa_run_sp_as_job @job_name, @spa, 'SSIS_RWE_DE_Endur', @user_login_id, 'SSIS', @system_id, 'y'

				
		----if windows auth & msdb
        --SET @spa = N'/SQL "' + @package_name + '" /SERVER "' + @@SERVERNAME + '" /CHECKPOINTING OFF /REPORTING E /SET "\Package.Variables[User::PS_ProcessID].Properties[Value]";"' + @process_id + '" /SET "\Package.Variables[User::PS_UserName].Properties[Value]";"' + @user_login_id + '"'

		-- if windows auth
        --SET @spa = N'/FILE "' + @ssispath + '" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET "\Package.Variables[User::PS_BatchCreatedDateTime].Properties[Value]";"' +
        -- CONVERT(VARCHAR(20), GETDATE(), 120) + '" /SET "\Package.Variables[User::PS_ProcessID].Properties[Value]";"' + @process_id + '"'
        RETURN
	END


