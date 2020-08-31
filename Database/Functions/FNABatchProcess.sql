SET NOCOUNT ON

IF OBJECT_ID(N'[dbo].FNABatchProcess', N'FN') IS NOT NULL 
	DROP FUNCTION [dbo].FNABatchProcess
GO

/**
	A Generic function called by batch process and build script to generate file and notify to predefined users.

	Parameters
	@flag	:	Operation flag. 'c' used to generate file and notify to users.
	@batch_process_id	:	Unique process id
	@batch_report_param	:	SP execution call string. Avoid using it in new work.
	@time_finish	:	Process completed time recorded in process_log_tracker.
	@sp_or_file_name	:	Name of SP or file
	@reportname	:	Name of report. Same name with timestamp used to generate file.
*/

CREATE FUNCTION [dbo].[FNABatchProcess]
(
	@flag                CHAR(1),
	@batch_process_id    VARCHAR(100),
	@batch_report_param  VARCHAR(MAX),
	@time_finish         DATETIME,
	@sp_or_file_name     VARCHAR(500),
	@reportname          VARCHAR(100)
)
RETURNS VARCHAR(8000)
AS
	
	
BEGIN
	DECLARE @sql_str        VARCHAR(8000)
	DECLARE @process_table_name  VARCHAR(128)
	DECLARE @user_login_id  VARCHAR(50)
	DECLARE @job_name       VARCHAR(100)	
	DECLARE @trimmed_reportname VARCHAR(50)

	DECLARE @url						VARCHAR(3000),
				@desc						VARCHAR(3000),
				@url_batch_save				VARCHAR(3000),
				@email_message				VARCHAR(500),
				@notification_process_id	VARCHAR(50),
				@unique_file_name						NVARCHAR(2000),
				@output_file_extension		VARCHAR(5) = '.csv'
	SET @sql_str = ''
	SET @user_login_id = dbo.FNADBUser()
	SET @process_table_name = dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)

	IF @flag='s'
	BEGIN
		SET @process_table_name = dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
		SET @sql_str = '  into ' + @process_table_name + ' '
	END

	ELSE IF @flag = 'u' --update
	BEGIN
		 SET @sql_str = 'UPDATE process_log_tracker SET time_finished= ''' + CAST(@time_finish AS VARCHAR(20)) 
+''' WHERE process_id='''+@batch_process_id+''''
	END

	ELSE IF @flag = 'c' --completed
	BEGIN
		SET @batch_report_param = REPLACE(@batch_report_param, '''', '''''')
		
		
		
		SET @email_message = 'Batch process completed for <b>' + @reportname + '</b>.'
		--extract the last block in underscore separated values, this will be batch notificatio id (e.g. 7849994F_F198_4F6E_a57D_275C2760BC91_4ea5405292a42)
		SET @notification_process_id = dbo.FNAGetSplitPart(@batch_process_id, '_', 6)
		SET @job_name = 'report_batch_' + @batch_process_id	
		
		SELECT @output_file_extension = ISNULL(MAX(output_file_format), 'csv')
		FROM batch_process_notifications bpn 
		WHERE bpn.process_id = @notification_process_id
				   	
		IF EXISTS (SELECT 1 
		           FROM batch_process_notifications bpn 
		           WHERE bpn.process_id = @notification_process_id 
						AND bpn.csv_file_path IS NOT NULL)
		BEGIN
			--Use provided report name with username & timestamp for old logic
			IF LEFT(NULLIF(LTRIM(@sp_or_file_name), ''), 4) = 'spa_' OR @sp_or_file_name IS NULL
			BEGIN
				SET @unique_file_name = @reportname + '_' + REPLACE(dbo.FNADBUser(), '.', '_') + '_' + REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(20),GETDATE(),120),':',''), ' ', '_'), '-', '_') + @output_file_extension
			END   
			ELSE 
			BEGIN
				--Use provided file name. Append extension if not available in given file name.
				SET @unique_file_name  = @sp_or_file_name + CASE WHEN CHARINDEX(@output_file_extension, @sp_or_file_name) = 0 THEN @output_file_extension ELSE '' END
			END
			SET @url = '../../adiha.php.scripts/dev/shared_docs/temp_Note/' + @unique_file_name

			SELECT @desc = @email_message +
			CASE WHEN CHARINDEX('Temp_Note', csv_file_path)>0 THEN 'Report has been saved. Please <a target="_blank" href="' + @url + 
						'"><b>Click Here</a></b> to download.'
			 ELSE 'Report has been saved at <b>' + csv_file_path + '</b>.' 
			END  
			FROM batch_process_notifications bpn 
			WHERE bpn.process_id = @notification_process_id
			
			SET @sql_str = 'spa_message_board ''u'', ''' + @user_login_id + ''', NULL, 
							''' + @reportname + ''',
							''' + @desc + ''', '''', '''', ''s'',
							''' + @job_name + ''', NULL,
							''' + @batch_process_id + ''', NULL, NULL,
							''' + @process_table_name + ''', ''y'', ''' + @email_message + ''', 
							''' + @batch_report_param + '''
							, NULL, NULL,NULL, ''' + @unique_file_name + ''''	
		END
	END
	ELSE IF @flag = 'p'--Display processing message.
	BEGIN
		 SET @url = ''
		 
		SELECT @desc = 'Batch process completed for <b>' + @reportname 
					 + '</b>.</a>File is being saved. Please refresh for status.</>'
		 
		 SET @job_name = 'report_batch_' + @batch_process_id
		 SET @sql_str = 'spa_message_board ''u'', ' + @user_login_id + 
						 ', NULL, NULL, ''' + @desc + ''', '''', '''', ''s'', ' 
						 + @job_name +', NULL, NULL, NULL, ''n'''
	END

	RETURN @sql_str
END
