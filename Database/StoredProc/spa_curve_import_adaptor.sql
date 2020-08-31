
IF OBJECT_ID(N'[dbo].[spa_curve_import_adaptor]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_curve_import_adaptor]
    
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 --===========================================================================================================
 --Author: ssingh@pioneersolutionsglobal.com
 --Create date: 2012-05-15
 --Description: The procedure generates the name of the staging table of the different curves (price, volatility and correlation)
 --				that have been created in the SSIS package.then imports the data from them serially if the tables arent empty.

 -- params:
 --@process_id VARCHAR(50)- Process ID
 --@user_login_id VARCHAR(50) - UserID

 --===========================================================================================================

CREATE PROCEDURE [dbo].spa_curve_import_adaptor
	@process_id VARCHAR(50),
	@user_login_id VARCHAR(50)

AS 
/*
DECLARE @process_id VARCHAR(50)
		,@user_login_id VARCHAR(50)
SET @process_id = '20121226_105800'	
SET @user_login_id = 'farrms_admin'
 --*/	
DECLARE @sql VARCHAR(8000)
DECLARE @stage_table_price VARCHAR(250)
DECLARE @stage_table_volatility VARCHAR(250)
DECLARE @stage_table_correlation VARCHAR(250)
DECLARE @url VARCHAR(500)
DECLARE @desc VARCHAR(500)
DECLARE @errorcode VARCHAR(200)

--select code,value_id from static_data_value where value_id  IN (4008,4027,4026)

IF @user_login_id IS NULL
BEGIN 
	SET @user_login_id=dbo.FNADBUser()
END 

SELECT  @stage_table_price = dbo.FNAProcessTableName('source_price_curve', @user_login_id, @process_id)
SELECT  @stage_table_volatility = dbo.FNAProcessTableName('curve_volatility', @user_login_id, @process_id)
SELECT  @stage_table_correlation = dbo.FNAProcessTableName('curve_correlation', @user_login_id, @process_id)

CREATE TABLE #existance(table_type INT)

SET @sql = 'INSERT INTO #existance(table_type) SELECT 1 FROM ' + @stage_table_price
EXEC(@sql)
SET @sql = 'INSERT INTO #existance(table_type) SELECT 2 FROM ' + @stage_table_correlation
EXEC(@sql)
SET @sql = 'INSERT INTO #existance(table_type) SELECT 3 FROM ' + @stage_table_volatility
EXEC(@sql)

IF EXISTS(SELECT 1 FROM #existance WHERE table_type = 1)
BEGIN 
	DECLARE @job_name_price AS VARCHAR(150)
	SET @job_name_price = 'importdata_price_'+ @process_id
	EXEC [spa_import_data_job]  @stage_table_price ,4008,@job_name_price,@process_id,@user_login_id, 'y'
	
END 

IF EXISTS(SELECT 1 FROM #existance WHERE table_type = 2)
BEGIN 
	DECLARE @job_name_correlation AS VARCHAR(150)
	SET @job_name_correlation = 'importdata_correlation_'+ @process_id
	EXEC [spa_import_data_job]  @stage_table_correlation , 4026, @job_name_correlation, @process_id, @user_login_id, 'y'
	
END 

IF EXISTS(SELECT 1 FROM #existance WHERE table_type = 3)
BEGIN 
	DECLARE @job_name_volatility AS VARCHAR(150)
	SET @job_name_volatility = 'importdata_volatility_'+ @process_id
	EXEC [spa_import_data_job]  @stage_table_volatility , 4027, @job_name_volatility, @process_id, @user_login_id, 'y'
	
END 

CREATE TABLE #error_check ([source] varchar(100) COLLATE DATABASE_DEFAULT,code VARCHAR(50) COLLATE DATABASE_DEFAULT,process_id VARCHAR(100) COLLATE DATABASE_DEFAULT)

INSERT INTO #error_check ([source] ,code, process_id )
SELECT [source], code, process_id  FROM source_system_data_import_status WHERE [Process_id] = @process_id

If exists(SELECT 1 FROM #error_check WHERE code = 'Error')
BEGIN 
	SET @errorcode = 'e'
END 
ELSE 
BEGIN
	SET @errorcode = 's'
END	

SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
	'&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''

select @desc = '<a target="_blank" href="' + @url + '">' + 
			'Import process Completed for as of date:' + dbo.FNAUserDateFormat(getdate(), @user_login_id) + 
		case when (@errorcode = 'e') then ' (ERRORS found)' else '' end +
		'.</a>'
	--EXEC  spa_message_board 'i', @user_login_id,NULL, 'Import Data',@desc, '', '', @errorcode, 'job_name',null,@process_id
	--@job_name is passed null to use @process_id, which is in the form @process_id_@batch_unique_id, so that @batch_unique_id
	--can be extracted for notification processing defined in batch_process_notifications table.
	EXEC  spa_message_board 'i', @user_login_id,NULL, 'Import Data',@desc, '', '', @errorcode, NULL,null,@process_id
	
update import_data_files_audit
	set	status=@errorcode,
		elapsed_time=datediff(ss,create_ts,getdate())
	where process_id=@process_id
