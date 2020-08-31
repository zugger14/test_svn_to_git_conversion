
-- exec spa_run_Import_package 'l','t','spc'
--exec spa_run_Import_package 'e','em','ei'
IF OBJECT_ID('spa_run_Import_package','p') IS NOT NULL
DROP PROC [dbo].[spa_run_Import_package]
GO
/*
	Author : Vishwas Khanal
	Dated  : 01.13.2009
	Desc   : This SP will call the SSIS package. Mainly used to overwrite the config file. 
*/
CREATE PROC [dbo].[spa_run_Import_package]
	@projectFlag	CHAR(1),
	@source_system  VARCHAR(2)=NULL,
	@import_source  VARCHAR(5)=NULL,
	@import_from	CHAR(1)	  =NULL,
	@dateFrom		DATETIME  =NULL
	
AS 
BEGIN
	DECLARE @cmd			VARCHAR(1000)	,
			@ssispath		VARCHAR(1000)	,
			@configfile		VARCHAR(200)	,
			@folder			VARCHAR(500)	,			
			@year			VARCHAR(4)		,
			@month			VARCHAR(2)		,
			@day			VARCHAR(2)		,
			@root			VARCHAR(50),
			@user_name		VARCHAR(50)

/*
	@projectFlag	: l - ladwp,'e' - emission,'r' -RWE
	@import_source  : 'spc' - source price curve
	@import_from    : p - postclose
					  t - today
					  d - date
					  y - yesterday
					  k - day before yesterday
	@source_system  : p - platts
					  n - nymex
					  t - treasury
	
*/		
	BEGIN TRY
		
--DECLARE @process_id varchar(50)
--SET @process_id=dbo.FNAGetNewID()		
--CREATE TABLE #returnval (
--	ErrorCode VARCHAR(500) COLLATE DATABASE_DEFAULT, 
--	Mesage VARCHAR(500) COLLATE DATABASE_DEFAULT,
--	Area VARCHAR(100) COLLATE DATABASE_DEFAULT,
--	Status VARCHAR(50) COLLATE DATABASE_DEFAULT,
--	Module VARCHAR(500) COLLATE DATABASE_DEFAULT,
--	Recommendation VARCHAR(500) COLLATE DATABASE_DEFAULT
--)		
		
	set @user_name=ISNULL(@user_name,dbo.FNADBUser())
		SELECT @root = import_path FROM connection_string
	
		IF @projectFlag	= 'l'
		BEGIN
			IF @import_source = 'spc'
			BEGIN
				SELECT @ssispath	= @root+'\Deliverables\ladwp.dtsx'
				SELECT @configfile  = @root+CASE @source_system 
											WHEN 'p' THEN '\Deliverables\config_platts.dtsconfig'
											WHEN 'n' THEN '\Deliverables\config_nymex.dtsconfig'
											WHEN 't' THEN '\Deliverables\config_treasury.dtsconfig'
										END

				IF @source_system = 'p' 
				BEGIN
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
						SELECT @folder = '/pub/' + @folder + '/*.*'
			
						SELECT @cmd = 'dtexec /FILE "'+@ssispath+'"  /CONFIGFILE "'+@configfile+'" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET \Package.Variables[User::ps_ftpLocForPriceCurves].Properties[Value];"' + @folder + '"' 

				END	
				ELSE IF @source_system IN  ('n','t')
							SELECT @cmd = 'dtexec /FILE "'+@ssispath+'"  /CONFIGFILE "'+@configfile+'" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E'			
			END		
		END
		IF @projectFlag	= 'e'
		BEGIN
			IF @source_system = 'em' and @import_source = 'ei'
			BEGIN
				SELECT @ssispath	= @root+'\Package.dtsx'
				SELECT @configfile  =  @root+'\vectren_edr_config.dtsconfig'									
			END
				SELECT @cmd = 'dtexec /FILE "'+@ssispath+'"  /CONFIGFILE "'+@configfile+'" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E'			
		END	
		--dtexec /FILE "E:\Vecdeliverables\ladwp.dtsx"  /CONFIGFILE "E:\Vecdeliverables\vectren_edr_config.dtsconfig" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E
		IF @projectFlag	= 'r'
		BEGIN		
			IF @source_system = 're' and @import_source IS NULL
			BEGIN
				DECLARE @count INT --,@batchFilePath VARCHAR(1000)
--				SELECT @batchFilePath=@root+'\Batch\rweMover.bat'
--				EXEC master..xp_cmdshell @batchFilePath,no_output
				DECLARE @spa VARCHAR(5000)
				SELECT @count = 1
				SELECT @root = import_path FROM connection_string
				set @ssispath = @root+'\rwe.dtsx'

				WHILE(@count <=3)
				BEGIN
					
				/*	
							SELECT @root = import_path FROM connection_string
						SELECT @ssispath = @root+'\rwe.dtsx',@configfile=@root+@ssis_configfile
						set @spa=N'/FILE "'+@ssispath+'" /CONFIGFILE "'+@configfile+'" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET \Package.Variables[User::ps_workspace].Properties[Value];"'+@root+'" /SET \Package.Connections[Staging Table Insertion].Properties[UserName];"' + @user_name +'" /SET \Package.Connections[Staging Table Insertion].Properties[Password];"Admin2929"'
						--SELECT @cmd = 'dtexec /FILE "'+@ssispath+'"  /CONFIGFILE "'+@configfile+'" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET \Package.Variables[User::ps_workspace].Properties[Value];"'+@root+'"'

					
					*/
					IF  @count = 1
					BEGIN
						set @spa=N'/FILE "'+@ssispath+'" /CONFIGFILE "'+@root+'\price.dtsconfig" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET \Package.Variables[User::ps_workspace].Properties[Value];"'+@root+'" /SET \Package.Connections[Staging_Table_Insertion].Properties[UserName];"'+ @user_name+ '" /SET \Package.Connections[Staging_Table_Insertion].Properties[Password];"Admin2929" '
						EXEC dbo.spa_run_sp_as_job 'RWE_PriceCurve',@spa,'SSIS_RWE_PriceCurve',@user_name,'SSIS'
					end
					ELSE IF  @count = 2
					BEGIN
						set @spa=N'/FILE "'+@ssispath+'" /CONFIGFILE "'+@root+'\deal.dtsconfig" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET \Package.Variables[User::ps_workspace].Properties[Value];"'+@root+'" /SET \Package.Connections[Staging_Table_Insertion].Properties[UserName];"'+ @user_name+ '" /SET \Package.Connections[Staging_Table_Insertion].Properties[Password];"Admin2929" '
						EXEC dbo.spa_run_sp_as_job 'RWE_Deal',@spa,'SSIS_RWE_Deal',@user_name,'SSIS'
					end
					ELSE IF  @count = 3
					BEGIN
						set @spa=N'/FILE "'+@ssispath+'" /CONFIGFILE "'+@root+'\mtm.dtsconfig" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET \Package.Variables[User::ps_workspace].Properties[Value];"'+@root+'" /SET \Package.Connections[Staging_Table_Insertion].Properties[UserName];"'+ @user_name+ '" /SET \Package.Connections[Staging_Table_Insertion].Properties[Password];"Admin2929" '
						EXEC dbo.spa_run_sp_as_job 'RWE_MTM',@spa,'SSIS_RWE_MTM',@user_name,'SSIS'
					END
					
/*
					SELECT @configfile = @root+CASE @count WHEN 1 THEN '\price.dtsconfig'
													 WHEN 2 THEN '\deal.dtsconfig'																			
													 WHEN 3 THEN '\mtm.dtsconfig'																			
					                           END
					                           
					                           
				insert into #returnval	EXEC dbo.spa_run_sp_as_job                            
				select @run_job_name='RWE_Deal',
				@spa='RWE_Deal',
				@proc_desc='SSIS_RWE_Deal',
				@user_login_id =@user_name,
				@job_subsystem ='SSIS'
				,@ssis_configfile='\test.axa'

					SELECT @cmd = 'dtexec /FILE "'+@ssispath+'"  /CONFIGFILE "'+@configfile+'" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET \Package.Variables[User::ps_workspace].Properties[Value];"'+@root+'"'
--					SELECT @cmd = 'dtexec /SQL "'+@ssispath+'"  /USER "' +@user_name +'" /PASSWORD "Admin2929" /CONFIGFILE "'+@configfile+'" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET \Package.Variables[User::ps_workspace].Properties[Value];"'+@root+'"'
					EXEC master..xp_cmdshell @cmd,no_output	

---/USER @user_name /PASSWORD 'Admin2929' /Server /SQL 
*/
					SELECT @count = @count + 1									
				END
			END
			RETURN
		END

		EXEC master..xp_cmdshell @cmd,no_output

		EXEC spa_ErrorHandler 0, 'Import Price', 
				'', 'Success', 
				'Import process has been run and will complete shortly. Please Check/Refresh your message board.', ''  				
	END TRY
			
	BEGIN CATCH			 
			EXEC spa_ErrorHandler -1, 'Import Price', 
					'', 'Error', 
					'Error in running the import process.Please contact the administrator.', ''
	END CATCH
END
		

			
