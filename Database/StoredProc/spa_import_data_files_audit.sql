IF OBJECT_ID(N'spa_import_data_files_audit', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_import_data_files_audit]
GO 



/*
EXEC spa_import_data_files_audit 's','2007-12-15','2008-12-27'
SELECT * FROM import_data_files_audit
--drop proc dbo.spa_import_data_files_audit
--go
--
--EXEC spa_import_data_files_audit 's',3,577,1,3,'test1_ee'
--
--EXEC spa_import_data_files_audit 's', '2014-12-02','2014-12-02',NULL,NULL,NULL,NULL,NULL,NULL,'y','n'



*/


CREATE PROC [dbo].[spa_import_data_files_audit]
	@flag AS CHAR(1),
	@start_date VARCHAR(20) = NULL,
	@END_date VARCHAR(20) = NULL,
	@process_id VARCHAR(150) = NULL,
	@dir_path VARCHAR(500) = NULL,
	@imp_file_name VARCHAR(500) = NULL,
	@as_of_date VARCHAR(20) = NULL,
	@status VARCHAR(20) = NULL,
	@elapsed_time FLOAT = NULL,
	@use_create_date CHAR(1) = NULL,
	@report_type CHAR(1) = NULL,
	@source_system_id INT = NULL,
	@import_source INT = NULL,
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
AS
/*******************************************1st Paging Batch START**********************************************/
SET NOCOUNT ON;
DECLARE @str_batch_table VARCHAR (8000)
DECLARE @user_login_id VARCHAR (50)
DECLARE @sql_paging VARCHAR (8000)
DECLARE @is_batch bit
SET @str_batch_table = ''
SET @user_login_id = dbo.FNADBUser() 
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 

IF @is_batch = 1
	SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)

IF @enable_paging = 1 --paging processing
BEGIN
	IF @batch_process_id IS NULL
		SET @batch_process_id = dbo.FNAGetNewID ()
	
	SET @str_batch_table = dbo.FNAPagingProcess ('p', @batch_process_id, @page_size, @page_no)
	
	--retrieve data from paging table instead of main table
	IF @page_no IS NOT NULL 
	BEGIN
		SET @sql_paging = dbo.FNAPagingProcess ('s', @batch_process_id, @page_size, @page_no) 
		EXEC (@sql_paging) 
		RETURN 
	END
END
/*******************************************1st Paging Batch END**********************************************/

DECLARE @url            VARCHAR(500)
DECLARE @desc           VARCHAR(500)
DECLARE @url_deal       VARCHAR(500)
DECLARE @import_code	VARCHAR(200)

--SELECT @import_source
IF @import_source IS NOT NULL
	SELECT @import_code = sdv.code FROM static_data_value sdv WHERE sdv.value_id = @import_source
ELSE
	SET @import_code = ''


IF @import_code = 'term_code_mapping'
	SET @import_code = 'Trayport'
	
IF @import_code = 'cma_price_curve_response'
	SET @import_code = 'Import CMA Data'	

IF @import_code = 'deal_detail_hour_lrs'
	SET @import_code = 'deal_detail_hour'
	
IF @flag='i'
BEGIN		
	IF @process_id is NULL 
	BEGIN
		SET @process_id = REPLACE(NEWID(),'-','_')			
	END
	
	DECLARE @audit_id INT
	
	INSERT import_data_files_audit
	  (
	    dir_path,
	    imp_file_name,
	    as_of_date,
	    STATUS,
	    elapsed_time,
	    process_id,
	    source_system_id
	  )
	VALUES
	  (
	    @dir_path,
	    @imp_file_name,
	    @as_of_date,
	    @status,
	    @elapsed_time,
	    @process_id,
	    @source_system_id
	  )
	  
	SET @audit_id=SCOPE_IDENTITY()
	IF @status='f'
	BEGIN
		INSERT INTO source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
		SELECT @process_id,
		       'Error',
		       'Import Data',
		       'Interface',
		       'Format Error',
		       'File ' + @imp_file_name + ' found invalid format.',
		       'Possible cause (comma missing, date format invalid, nos. of column and data doesn'
		       't match, source file might be in wrong folder structure), please verIFy the file and re-run the process. '
	END
	IF @status='n'
	BEGIN
		INSERT INTO source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
		SELECT @process_id,
		       'Error',
		       'Import Data',
		       'Interface',
		       'Format Error',
		       'File ' + @imp_file_name + ' found invalid naming conventions.',
		       'File naming conventions must be YYYYMMDD_SourceName_filename.csv'
	END
--	SELECT @process_id Process_ID
END
IF @flag='u'
BEGIN
	UPDATE import_data_files_audit
	SET    [status] = @status,
	       elapsed_time = @elapsed_time
	WHERE  Process_ID = @process_id
END
IF @flag = 'e'	--automatically calculates the elapsed time assuming start time as create_ts and end time as NOW.
BEGIN
	UPDATE import_data_files_audit
	SET    [status] = @status,
	       elapsed_time = DATEDIFF(ss, create_ts, GETDATE())
	WHERE  process_id = @process_id
END	
IF @flag = 'd'	--delete audit lof for empty file error .
BEGIN
	DELETE  FROM  import_data_files_audit
	WHERE  process_id = @process_id
END	
IF @flag='s'
BEGIN
	DECLARE @sql VARCHAR(5000)
	IF @report_type is null or @report_type='n'
	BEGIN
		SET @sql='
		SELECT dir_path [Directory Path],
		       imp_file_name [File Name],
		       dbo.FNADateFormat(as_of_date) [As of Date],
		       CASE 
		            WHEN STATUS = ''c'' THEN ''Completed''
		            WHEN STATUS = ''p'' THEN ''Processing''
		            WHEN STATUS = ''w'' THEN ''Warning''
		            WHEN STATUS = ''s'' THEN ''Success''
		            WHEN STATUS = ''f'' THEN ''<font color = red> Invalid Format </font> ''
		            ELSE ''<font color=red> ERROR Found </font>''
		       END [Status],
		       elapsed_time [Elapsed Time (Seconds)],
		       ''<a target="_blank" href="./spa_html.php?spa=exec '''
		       +CASE WHEN @import_source='4054' THEN ' spa_get_mtm_test_run_log ''''''+process_id+'''''',1' else 
			  ' + case when dir_path=''Regression Testing'' then  '' spa_get_import_process_status ''''''+process_id+'''''',''''''+idfa.create_user+'''''',null,''''Regression Testing'''''' 
			  else '' spa_get_import_process_status ''''''+process_id+'''''',''''''+idfa.create_user+'''''''' end ' end
				 +'+''&__user_name__=''+idfa.create_user+''">''+process_id+''.</a>''	   [Process ID], 
				 au.user_f_name + '' '' + au.user_l_name [Create User],
		       dbo.FNADateTimeFormat(idfa.create_ts, 1) [Create Time] ' + @str_batch_table + '
		FROM   import_data_files_audit idfa
		LEFT JOIN application_users  au ON  au.user_login_id = idfa.create_user 
		where dir_path LIKE ''%'+@import_code +'%'' AND 1=1 AND'

		IF @use_create_date ='y'
			SET @sql=@sql+' convert(varchar(10),isnull(idfa.create_ts,''1900-01-01''),120) between '''+ @start_date  +''' and '''+  @END_date +''''	 
		ELSE
			SET @sql=@sql+' isnull(as_of_date,''1900-01-01'') between isnull('''+ @start_date +''',''1900-01-01'') and isnull('''+ @END_date +''',''999-01-01'')'

		IF @process_id is not null
			SET @sql=@sql+' and process_id='''+ @process_id +''''

		SET @sql=@sql+' order by create_ts desc'
		--PRINT (@sql)
	END
	ELSE IF @report_type='z'
	BEGIN
	
		IF OBJECT_ID('tempdb..#date_seq') IS NOT NULL
			DROP TABLE #date_seq
		
		SELECT CAST(@start_date AS DATETIME) + n [dt]
		INTO #date_seq
		FROM dbo.seq
		WHERE CAST(@start_date AS DATETIME) + n <= @END_date
		
		
		SELECT dbo.fnadateformat(m.as_of_date) [As of date],
		       MAX(curve_name) [Curve name],
		       MAX(market_value_id) Source,
		       SUM(CASE WHEN spc.source_curve_def_id IS NULL THEN 0 ELSE 1 END) [Number of Records Imported],
		       '<a target="_blank" href="./spa_html.php?__user_name__=' + @user_login_id + '&spa=EXEC spa_maintain_price_curve ' + CAST(m.source_curve_def_id AS VARCHAR) + ' , 77, 4500, ''' + CONVERT(VARCHAR(10), m.as_of_date, 120) + ''', ''' + CONVERT(VARCHAR(10), m.as_of_date, 120) + ''', NULL, NULL, NULL, ''s'', NULL, NULL, NULL ,NULL, ''n''">View data</a>' Recommendation 
		FROM   (
		           SELECT dt as_of_date,
		                  source_curve_def_id,
		                  curve_id,
		                  curve_name,
		                  market_value_id
		           FROM   source_price_curve_def
		           CROSS JOIN #date_seq
		           WHERE  market_value_id IN ('Platts', 'Treasury Yield', 'Nymex')		           
		       ) m
		       LEFT JOIN source_price_curve spc ON  m.source_curve_def_id = spc.source_curve_def_id
		            AND m.as_of_date = spc.as_of_date
		GROUP BY m.source_curve_def_id, m.as_of_date
	END
	ELSE
	BEGIN	
		SELECT @url = './spa_html.php?spa=EXEC spa_get_import_process_status_detail '''''' + a.process_id + '''''
		SELECT @url_deal = './spa_html.php?spa=EXEC spa_get_missing_deal_log '''''' + a.process_id + '''''
		SELECT @desc = '<a target="_blank" href="' + @url + '">' 
		SET @sql='
			SELECT dir_path [Directory Path],
			       dbo.FNADateFormat(as_of_date) [As of Date],
			       CASE 
			            WHEN STATUS = ''c'' THEN ''Completed''
			            WHEN STATUS = ''p'' THEN ''Processing''
			            WHEN STATUS = ''w'' THEN ''Warning''
			            WHEN STATUS = ''s'' THEN ''Success''
			            WHEN STATUS = ''f'' THEN ''<font color=red> Invalid Format </font>''
			            ELSE ''<font color=red> ERROR Found </font>''
			       END [Status],
			       elapsed_time [Elapsed Time (Seconds)],
			       ''<a target="_blank" href="./spa_html.php?spa=exec spa_get_import_process_status ''''''+a.process_id+'''''',''''''+a.create_user+''''''''+''&__user_name__=''+a.create_user+''">''+a.process_id+''.</a>'' [Process ID],
			       d.Source,
			       CASE 
			            WHEN code IN (''ERROR'', ''Warrning'') AND source = ''Static_Data'' 
							THEN '' <a target="_blank" href="'+@url+''',''''''+d.source+'''''',''''''+d.description+''''''">''+d.description+''</a>'' 
			            WHEN (code = ''Warrning'' AND source = ''voided_deal'') OR (code = ''Success'' AND d.module = ''Calc Embedded'') OR (code = ''ERROR'' AND d.module = ''Schedule_log'') 
							THEN '' <a target="_blank" href="'+@url+''',''''''+d.source+''''''">''+d.description+''</a>''
			            WHEN (code = ''ERROR'' AND source = ''Deal_Not_Found'') 
							THEN '' <a target="_blank" href="'+@url_deal+'''">''+d.description+''</a>''
			            ELSE d.description
			       END AS [Description],
			       d.Recommendation,
			       a.create_user [Create User],
			       --a.create_ts [Create Time]
			       dbo.FNADateTimeFormat(a.create_ts, 1) [Create Time] ' + @str_batch_table + '
			FROM   import_data_files_audit a
			JOIN source_system_data_import_status d ON  a.process_id = d.process_id
			where dir_path LIKE ''%'+@import_code +'%'' AND 1=1 AND'

		IF @use_create_date ='y'
			SET @sql =  @sql + ' dbo.FNAConvertTZAwareDateFormat(isnull(a.create_ts,''1900-01-01''),1) between '''+ @start_date  +''' and '''+  @END_date +' 23:59:59'''
			--SET @sql = @sql + ' isnull(a.create_ts,''1900-01-01'') 
		ELSE
			SET @sql = @sql + ' isnull(as_of_date,''1900-01-01'') between isnull('''+ @start_date +''',''1900-01-01'') and isnull('''+ @END_date +''',''999-01-01'')'

		IF @process_id is not null
			SET @sql = @sql + ' and a.process_id=''' + @process_id + ''''

		SET @sql = @sql + ' order by a.create_ts desc'
		--PRINT (@sql)
	END
	EXEC(@sql)
END
/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board

IF @is_batch = 1
BEGIN
	SELECT @str_batch_table = dbo.FNABatchProcess ('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
	EXEC (@str_batch_table)
	SELECT @str_batch_table = dbo.FNABatchProcess ('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_import_data_files_audit', 'Import Audit Report')
	EXEC (@str_batch_table)
	RETURN
END

--if it is first call from paging, return total no. of rows and process id instead of actual data
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
	SET @sql_paging = dbo.FNAPagingProcess ('t', @batch_process_id, @page_size, @page_no)
	EXEC (@sql_paging)
END
/*******************************************2nd Paging Batch END**********************************************/









