

IF OBJECT_ID(N'spa_import_ice_forward_price', N'P') IS NOT NULL
BEGIN
    DROP PROCEDURE spa_import_ice_forward_price
END

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE spa_import_ice_forward_price
	@flag CHAR(1) = NULL,
	@process_id VARCHAR(50) = NULL,
	@user_login_id VARCHAR(50) = NULL,
	@error_code INT = NULL,
	@filename VARCHAR(255) = '',
	@as_of_date VARCHAR(10) = NULL,
	@custom_table VARCHAR(255) = NULL
AS


        --'error code -1: no error, file does not exists in url but file copied manually in folder
        --'error code 0: no error, file successfully downloaded from url
        --'error code 1: script error
        --'error code 2: DFT fail error
        --'error code 3: unhandled/unknown exception
        --'error code 404: file does not exists in url
        --'error code 403: file access forbidden
        --'error code 401: file unauthorized, pwd incorrect
        
	DECLARE @load_table  VARCHAR (256) = NULL
	DECLARE @sql VARCHAR(MAX), @job_name VARCHAR(500), @url varchar(500), @errorcode CHAR(1)
	IF @user_login_id IS NOT NULL
	BEGIN
		DECLARE @contextinfo VARBINARY(128)
		SELECT @contextinfo = CONVERT(VARBINARY(128), @user_login_id)
		SET CONTEXT_INFO @contextinfo
    END
	SET @user_login_id = ISNULL(NULLIF(@user_login_id, ''), dbo.fnadbuser())
	SET @process_id = ISNULL(NULLIF(@process_id, ''), REPLACE(NEWID(), '-', '_'))

	IF @custom_table IS NOT NULL
	BEGIN
		SET @load_table = @custom_table  --'adiha_process.dbo.IcePriceCurveImport_' + @user_login_id + '_' + @process_id
	END
	ELSE
	SET @load_table = 'adiha_process.dbo.ice_forward_price_' + @user_login_id + '_' + @process_id

	SET @job_name = 'importdata_ice_power_data_' + @process_id

IF @flag = 'c'
BEGIN
	SET @sql = 'IF OBJECT_ID(''' + @load_table + ''') IS NOT NULL
	DROP TABLE ' + @load_table 
	EXEC(@sql)
		
	SET @sql = 
		'CREATE TABLE ' + @load_table + 
		'(
			id INT IDENTITY (1,1),
			trade_date NVARCHAR(255),
			hub NVARCHAR(255),
			product NVARCHAR(255),
			strip NVARCHAR (255),
			contract NVARCHAR(255),
			contract_type NVARCHAR(255),
			strike NVARCHAR(255),
			settlement_price NUMERIC(38,20),
			net_change NUMERIC(38,20),
			expiration_date NVARCHAR(255),
			product_id NVARCHAR(255),
			price_of NVARCHAR(50)
		)'

	EXEC(@sql)
	SELECT @load_table loadtable
	
	--PRINT(@sql)	
END
ELSE IF @flag = 'f'
BEGIN 

DECLARE @download_file_name VARCHAR(255), 
		@download_date_str VARCHAR(10), 
		@current_ts DATETIME = GETDATE(), 
		@download_date DATE = ISNULL(NULLIF(@as_of_date, ''), CONVERT(VARCHAR(10), GETDATE(), 120))

-- initiate import audit log,
IF NOT EXISTS (SELECT 1 FROM import_data_files_audit WHERE process_id = @process_id)
BEGIN
	EXEC spa_import_data_files_audit 'i', @current_ts, NULL, @process_id, 'ICE Forward Price Import', 'source_price_curve', @current_ts, 'p', NULL
END

SELECT @download_date_str = REPLACE(@download_date,'-','_')

--SET @download_file_name = 'icecleared_gas_' + @download_date_str + '.xlsx'
SELECT  @process_id processid


END
ELSE IF @flag = 'e'
BEGIN

	DECLARE @status CHAR(1), @elapsed_sec FLOAT, @start_ts DATETIME, @desc VARCHAR(8000) = '', 
	@desc2 VARCHAR(1000) = 'Data may not be available in the source.Please check the data source.'
	SELECT @start_ts = ISNULL(MIN(create_ts),GETDATE()) FROM import_data_files_audit WHERE process_id = @process_id
	SET @elapsed_sec = DATEDIFF(SECOND, @start_ts, GETDATE())
	IF @error_code = 401
	BEGIN
		SET @status = 'e'
		SET @desc = 'Error:401 Unauthorized'	
		SET @desc2 = 'Not authorised to read from data source. Please verify authentication'
	END
	ELSE IF @error_code = 403
	BEGIN
		SET @status = 'e'
		SET @desc = 'Error:403 Read forbidden'	
		SET @desc2 = 'Forbidden to read from data source. Please verify authentication'
	END
	ELSE IF @error_code = 404
	BEGIN
		SET @status = 'w'
		SET @desc = 'ICE File not Found'
	END
	ELSE IF @error_code = 2
	BEGIN
		SET @status = 'e'
		SET @desc = 'Data Flow Error. Error in file or format'
		SET @desc2 = 'Invalid File Format'
	END	
	ELSE IF @error_code = 1
	BEGIN
		SET @status = 'e'
		SET @desc = 'Script error'
		SET @desc2 = 'Error in script. Please contact administrator'
	END

	INSERT  INTO  source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
	SELECT  @process_id, 'Error', 'Import Data', @filename, 'Data Error', @desc, 'n/a'
	INSERT  INTO  source_system_data_import_status_detail(process_id,source,type,[description]) 
	SELECT  @process_id, @filename, 'Data Error', @desc2

	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
	'&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''

	SELECT  @desc = '<a target="_blank" href="' + @url + '">' + 
	'Import process Completed for ICE Forward Price on as of date:' + dbo.FNAUserDateFormat(getdate(), @user_login_id) + ' (ERRORS found)'+
	'.Elapsed time:' + CAST(@elapsed_sec AS VARCHAR(400)) + ' sec.
	</a>'
	
	UPDATE import_data_files_audit SET [status] = @status, elapsed_time = @elapsed_sec, [description] = @desc, imp_file_name = @filename WHERE Process_ID = @process_id
	--EXEC  spa_message_board 'i', @user_login_id, NULL, 'Import Data', @desc, '', '', 'e', @job_name,null,@process_id
	EXEC spa_NotificationUserByRole 2, @process_id, 'Import Data', @desc, 'e', @job_name, 1

END
ELSE IF @flag = 'i'
BEGIN
	
	IF OBJECT_ID('tempdb..#staging_tbl') IS NOT NULL
	BEGIN
		DROP TABLE #staging_tbl
	END
	CREATE TABLE #staging_tbl(tbl_name VARCHAR(1000) COLLATE DATABASE_DEFAULT )

	BEGIN TRY
		
		INSERT INTO #staging_tbl EXEC spa_import_temp_table '4008', @process_id
		DECLARE @staging_tbl VARCHAR(500)
		SELECT @staging_tbl = tbl_name FROM #staging_tbl
	
		EXEC('
			INSERT INTO ' + @staging_tbl + '
			(
				source_curve_def_id,
				source_system_id,
				as_of_date,
				Assessment_curve_type_value_id,
				curve_source_value_id,
				maturity_date,
				maturity_hour,
				curve_value,
				is_dst,
				table_code
			)	
			SELECT   spcd.curve_id,
					2 [source_system_id],
					CONVERT(VARCHAR(10), CONVERT(DATETIME, t.trade_date), 120) [as_of_date],
					77 [Assessment_curve_type_value_id],
					4500 [curve_source_value_id],
					CONVERT(VARCHAR(10), CONVERT(DATETIME, t.strip), 120) [maturity_date],
					NULL [maturity_hour],
					REPLACE(REPLACE(REPLACE(t.settlement_price, '' '', ''''), CHAR(13), ''''), CHAR(10), '''') [curve_value],
					0 [is_dst],
					4008 [table_code]		 
			FROM ' + @load_table + ' t
			INNER JOIN source_price_curve_def spcd on spcd.curve_id = t.hub + '' '' + t.product
		')		

	--	EXEC('ALTER TABLE ' + @staging_tbl + ' ADD temp_id INT IDENTITY(1,1)')	
	
		EXEC spa_import_data_job @staging_tbl, 4008, @job_name, @process_id, @user_login_id, 'n', NULL, NULL, NULL  
		
		DECLARE @count INT 
		SELECT @count=COUNT(1) FROM source_system_data_import_status_detail WHERE process_id = @process_id AND ([type]='Error' OR [type]='Data Error'OR [type]='Data Warning')
		IF @count >0
		BEGIN
			SET @errorcode='e'
		END
		ELSE
		BEGIN
			SET @errorcode='s'
		END

		--EXEC spa_NotificationUserByRole 2, @process_id, 'Import Data', @desc, @errorcode, @job_name, 1
	
	END TRY
	BEGIN CATCH
		/* 
			SELECT
				ERROR_NUMBER() AS ErrorNumber,
				ERROR_SEVERITY() AS ErrorSeverity,
				ERROR_STATE() AS ErrorState,
				ERROR_PROCEDURE() AS ErrorProcedure,
				ERROR_LINE() AS ErrorLine,
				ERROR_MESSAGE() AS ErrorMessage
		*/
		INSERT  INTO  source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
		SELECT  @process_id,'Error','Import Data','source_price_curve','Data Error','Exception occured','n/a'
	
		INSERT  INTO  source_system_data_import_status_detail(process_id,source,type,[description]) 
		SELECT  @process_id,'source_price_curve','Data Error',ERROR_MESSAGE()
	
		SET @errorcode='e'

	END CATCH

	SELECT  @start_ts = ISNULL(MIN(create_ts),GETDATE()) FROM import_data_files_audit WHERE process_id = @process_id
	SET @elapsed_sec = DATEDIFF(SECOND, @start_ts, GETDATE())	
	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''
	SELECT @desc = '<a target="_blank" href="' + @url + '">' + 
	'Import process Completed for Ice Forward Price for as of date:' + dbo.FNAUserDateFormat(GETDATE(), @user_login_id) 
	+ CASE WHEN (@errorcode = 'e') THEN ' (ERRORS found)' ELSE '' END 
	+ '.Elapsed time:' + CAST(@elapsed_sec AS VARCHAR(1000)) + ' sec.</a>' 
	
	--UPDATE source_system_data_import_status SET rules_name = 'ICE Forward Price Import'  --, source = 'source_price_curve'+ CASE WHEN @error_code = -1 THEN '(Manual)' ELSE '' END 
	--WHERE process_id = @process_id
	UPDATE import_data_files_audit SET [status] = @errorcode, elapsed_time = @elapsed_sec --, imp_file_name = 'source_price_curve' + CASE WHEN @error_code = -1 THEN '(Manual)' ELSE '' END
	--, import_source = 'ixp_source_price_curve_template'
	 WHERE Process_ID = @process_id
		
	--EXEC  spa_message_board 'u', @user_login_id, NULL, 'Import Data', @desc, '', '', @errorcode, @job_name,null,@process_id
	EXEC spa_NotificationUserByRole 2, @process_id, 'Import Data', @desc, @errorcode, @job_name, 1

END

GO
