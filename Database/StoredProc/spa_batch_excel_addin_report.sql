
IF OBJECT_ID(N'[dbo].[spa_batch_excel_addin_report]', N'P') IS NOT NULL    
	DROP PROCEDURE [dbo].[spa_batch_excel_addin_report]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ============================================================================================================================
-- Author: Navaraj Shrestha
-- Create date: 2016-12-12
-- Description: Deploy RDL.
--              
-- Params:
-- @rdl_spa VARCHAR(5000) - SQL
-- @proc_desc VARCHAR (100) - SQL Desc
-- @user_login_id VARCHAR(50) - farrms_admin
-- @job_subsystem VARCHAR(100) = 'SSIS'

--****** IMPORTANT NOTE *******
-- PRINT COMMAND SHOULD NOT BE ENABLED IN THIS PROCEDURE AS IT WILL BREAK THE EXPORT TO TABLE LOGIC.
-- PRINT generates 'SUCCESS_WITH_INFO' diagnostic records (one for each print call),
-- which allows to capture the output over ODBC. With SQL Server once you start pulling diagnostic records
-- , you must pull them all, otherwise you block your database connection, leading to invalid cursor state errors when you try to fetch.

-- ============================================================================================================================

CREATE PROCEDURE [dbo].[spa_batch_excel_addin_report] 
	@excel_report_param			VARCHAR(MAX) = NULL
	, @report_name				VARCHAR(100) = NULL
	, @file_name				VARCHAR(100) = NULL
	, @proc_desc				VARCHAR (100) = NULL
	, @user_login_id			VARCHAR(50) = NULL
	, @job_subsystem			VARCHAR(100) = 'TSQL'
	, @email_description		VARCHAR(MAX) = NULL
	, @email_subject 			VARCHAR(MAX) = NULL
	, @batch_process_id			VARCHAR(50) = NULL
    , @batch_report_param		VARCHAR(1000) = NULL
	
AS
SET NOCOUNT ON

DECLARE @is_batch BIT
 
SET @user_login_id = dbo.FNADBUser() 
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 

IF @batch_process_id IS NULL
      SET @batch_process_id = dbo.FNAGetNewID()

DECLARE @report_snapshot_cmd	 VARCHAR(8000)

--SET @report_snapshot_cmd = '
CREATE TABLE #temp_return_msg (return_msg VARCHAR(20) COLLATE DATABASE_DEFAULT );

INSERT INTO #temp_return_msg
EXEC spa_synchronize_excel_reports '', @excel_report_param

DECLARE @desc VARCHAR(MAX)
DECLARE @job_name VARCHAR(200)
DECLARE @report_file_path VARCHAR(200)
DECLARE @notification_type INT
DECLARE @email_enable CHAR(1) = 'n'

--Update message board

IF EXISTS (SELECT 1 FROM #temp_return_msg WHERE return_msg = 'Success')
	BEGIN 
		SET @desc = 'Report Snapshot Job ' + ISNULL('for ' + @file_name,'') + ' has been completed.'		

		IF isnull(@report_name,'') =  ''
			SET @job_name = 'Report_Snapshot_Job_' + isnull(@report_name,'') + '_' + isnull(@batch_process_id,'')
		ELSE 
			SET @job_name = 'Report_Snapshot_Job_' + isnull(@batch_process_id,'')
		
		--extra
		--SELECT @compress_file = compress_file
		--FROM   batch_process_notifications bpn
		--	LEFT JOIN application_role_user aru ON  bpn.role_id = aru.role_Id
		--WHERE  bpn.process_id = RIGHT(@process_id, 13)
		--extra end
		
		IF EXISTS (SELECT 1 FROM   batch_process_notifications bpn
					LEFT JOIN application_role_user aru ON  bpn.role_id = aru.role_Id
				WHERE  bpn.process_id = RIGHT(@batch_process_id, 13) AND bpn.notification_type IN (750,752,754,756))
		BEGIN
			SET @email_enable = 'y'	
		
			IF @email_subject IS NULL
				SET @email_subject = 'TRM Snapshot Notification'
			SET @email_description = @desc
		END
		
		
		DECLARE @path VARCHAR(500) = ''
			
		SELECT @path = document_path
					FROM   connection_string
					
		-- set file paths
		SET @report_file_path = ''
						
		SELECT 
			@report_file_path =  @report_file_path + CASE WHEN @report_file_path <> '' THEN ';' ELSE '' END + isnull(@path,'') + '\Excel_Reports\' + ess.snapshot_filename
		FROM 
		excel_file ef			
		INNER JOIN excel_sheet es ON ef.excel_file_id = es.excel_file_id
		INNER JOIN excel_sheet_snapshot ess ON ess.excel_sheet_id = es.excel_sheet_id
		LEFT JOIN static_data_value sdv11 ON sdv11.value_id = es.category_id  
		CROSS APPLY (
		SELECT MAX(excel_sheet_snapshot_id)     lastest_snapshot_id
		FROM   excel_sheet_snapshot e
		WHERE  e.excel_sheet_id = es.excel_sheet_id
		)
		rs_lates
		WHERE  es.[snapshot] = 1
			AND ef.[file_name] = @file_name
			AND rs_lates.lastest_snapshot_id = ess.excel_sheet_snapshot_id
				
		SELECT @path = MAX(bpn.csv_file_path)
		FROM   batch_process_notifications bpn
		LEFT JOIN application_role_user aru ON  bpn.role_id = aru.role_Id
		WHERE  bpn.process_id = RIGHT(@batch_process_id, 13) --AND bpn.attach_file = 'y'		
		
		--Pick path from connection_string if not defined in batch_process_notifications.
		SELECT @path = ISNULL(@path,document_path) from connection_string
		--SELECT * FROM dbo.FNASplit(@report_file_path, ';') AS f
		
		IF EXISTS (SELECT 1 
			FROM   batch_process_notifications bpn
					LEFT JOIN application_role_user aru ON  bpn.role_id = aru.role_Id
				WHERE  bpn.process_id = RIGHT(@batch_process_id, 13) AND bpn.csv_file_path <> @path + 'temp_Note\'
					)			
		BEGIN
			
			DECLARE @item VARCHAR(200)
			DECLARE @dest_path VARCHAR(200)
			DECLARE @result VARCHAR(100)
			
			DECLARE cur_emp CURSOR
			STATIC FOR 
			SELECT item from dbo.FNASplit(@report_file_path, ';')
			OPEN cur_emp
			IF @@CURSOR_ROWS > 0
			BEGIN 
			FETCH NEXT FROM cur_emp INTO @item
			WHILE @@Fetch_status = 0
			BEGIN
					SET @dest_path = @path + '\' + reverse(left(reverse(@item),charindex('\',reverse(@item))-1))
					EXEC [spa_copy_file] @item, @dest_path, @result OUTPUT
					
			FETCH NEXT FROM cur_emp INTO @item
			END
			END
			CLOSE cur_emp
			DEALLOCATE cur_emp
		END
		
		IF EXISTS (SELECT 1 FROM   batch_process_notifications bpn
					LEFT JOIN application_role_user aru ON  bpn.role_id = aru.role_Id
				WHERE  bpn.process_id = RIGHT(@batch_process_id, 13) AND bpn.attach_file = 'n')
		BEGIN
			SET @report_file_path = NULL				
				
		END		

		EXEC spa_message_board 'u', @user_login_id, NULL, 'Report Snapshot ', @desc, '', '', 's', @job_name, NULL, @batch_process_id,NULL,NULL,NULL,@email_enable,@email_description,NULL,NULL,NULL,NULL,NULL,NULL, @report_file_path,@email_subject
		--SET @export_cmd_success = 'EXEC ' + @db_name + '.dbo.spa_message_board ''u'', ''' + @user_name + ''', NULL, ''' + @proc_desc  + ''', ''' + @desc_success + ''', '''', '''', ''s'', '''+@export_job_name+''',NULL, ''' + @process_id + ''',NULL,NULL,NULL,''y'',''' + @email_description + ''',NULL,NULL,NULL,NULL,NULL,NULL,''' + @report_file_path  + ''',''' + @email_subject + ''', '+@is_aggregate_var+''
	END
ELSE
	BEGIN
		RAISERROR ('Failed to create report snapshot.', -- Message text.
           16, -- Severity.
           1 -- State.
           );
	END
--'
--PRINT @report_snapshot_cmd
--EXEC(@report_snapshot_cmd)
