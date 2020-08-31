IF OBJECT_ID('spa_generate_job_import_deal_detail_hour') IS NOT NULL
	DROP PROC [dbo].[spa_generate_job_import_deal_detail_hour]
GO

CREATE PROC dbo.spa_generate_job_import_deal_detail_hour 
	@import_type INT,
	@tbl_name VARCHAR(100),
	@user_login_id VARCHAR(30) = NULL,
	@process_id VARCHAR(50) = NULL
AS
DECLARE @spa VARCHAR(MAX), @job_name VARCHAR(150), @i TINYINT
DECLARE @ssispath VARCHAR(5000), @root VARCHAR(1000), @ssis_no_jobs int

SET @user_login_id = ISNULL(@user_login_id, dbo.FNADBUser())
IF @process_id IS NULL
	SET @process_id = dbo.FNAGetNewID()

SELECT @ssis_no_jobs = var_value
FROM adiha_default_codes_values
WHERE (instance_no = '1') AND (default_code_id = 32) AND (seq_no = 1)
SET @i = 1

EXEC dbo.spa_initialize_deal_detail_hour_import_from_staging @process_id, @user_login_id

SELECT @root = dbo.FNAGetSSISPkgFullPath('PRJ_LoadForecastDataImportIS', 'User::PS_PackageSubDir')
SELECT @ssispath = @root + 'LoadForecastDataImport.dtsx'

--set @spa=N'/FILE "'+@ssispath+'" /CONFIGFILE "'+@root+'\config.dtsConfig" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET \Package.Connections[Staging_Table_Insertion].Properties[UserName];"'+ @user_login_id+ '" /SET \Package.Variables[User::ps_batchCreatedDateTime].Properties[Value];"'+  convert(varchar(20),getdate(),120) +'"'
SET @spa = N'/FILE "' + @ssispath + '" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET "\Package.Variables[User::PS_ProcessID].Properties[Value]";"' + @process_id + '" /SET "\Package.Connections[OLE_CONN_MainDB].Properties[UserName]";"' + @user_login_id + '"'

SET @ssis_no_jobs = 1
WHILE @i <= ISNULL(@ssis_no_jobs, 1)
BEGIN
	SET @job_name = 'spa_generate_job_import_deal_detail_hour_' + RIGHT('0' + CAST(@i AS VARCHAR), 2) + '_' + @process_id
	EXEC dbo.spa_run_sp_as_job @job_name, @spa, 'Hourly_load_data', @user_login_id, 'SSIS', @import_type, 'n'
	SET @i = @i + 1
END
