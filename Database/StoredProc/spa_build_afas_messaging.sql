IF OBJECT_ID(N'spa_build_afas_messaging', N'P') IS NOT NULL
DROP PROCEDURE spa_build_afas_messaging
GO 

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_build_afas_messaging]
	@flag CHAR(1), 
	@type VARCHAR(50) = NULL, 
	@process_id VARCHAR(50) = NULL,
	@file_name VARCHAR(100) = NULL,
	@file_location VARCHAR(1000) = NULL,
	@message VARCHAR(MAX) = NULL		
AS
SET NOCOUNT ON 

DECLARE @user_name VARCHAR(50) = dbo.FNAdbuser()
DECLARE @desc_success VARCHAR(MAX)
--DECLARE @process_id VARCHAR(100)
DECLARE @url VARCHAR(MAX), @afas_process_table VARCHAR(100)
IF @flag = 'm'
BEGIN
	SET @process_id = dbo.FNAGetNewID() -- New process_id for new entry in message_board

	IF @type = 'Success'
	BEGIN
		SET @desc_success = 'GL entries have been posted successfully. Please <a target="_blank" href="../../adiha.php.scripts/force_download.php?path=dev/shared_docs/temp_Note/' + @file_name + '"><b>Click Here</b></a> to download the JSON file.'
		EXEC spa_message_board 'i',  @user_name , NULL, 'AFAS' , @desc_success , '', '', 's', NULL,NULL, @process_id
	END
	ELSE
	IF @type = 'Failed'
	BEGIN
		SET @desc_success = @message + 'Please <a target="_blank" href="../../adiha.php.scripts/force_download.php?path=dev/shared_docs/temp_Note/' + @file_name + '"><b>Click Here</b></a> to download the JSON file.'
		INSERT INTO source_system_data_import_status (process_id, code, module, source, type, description)
		SELECT @process_id, 'Failed', 'AFAS Interface', 'AFAS Interface', 'Error', @desc_success

		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + '&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_name+''''
 	
		SELECT @desc_success = '<a target="_blank" href="' + @url + '">Failed to post GL entries</a>. '
		EXEC spa_message_board 'i', @user_name,  NULL, 'AFAS', @desc_success, '', '', 's',  NULL, NULL, @process_id

	END
END
ELSE IF @flag = 'a'
BEGIN
	SET @afas_process_table = dbo.FNAProcessTableName('batch_report', @user_name, @process_id)	
	SET @message = REPLACE(@message, '''', '''''')
	EXEC ('
		INSERT INTO afas_web_service_audit (
		 [year]								
		, [month]								
		, [VaAs]								
		, [acnr]								
		, [acnr_cr]							
		, [enda]								
		, [bpda]								
		, [bpnr]								
		, [DS]								
		, [amde]								
		, [U74D074944DB70225689641899DF32441] 
		, [U5E53591548A7A7DDF601A0A42217039E] 
		, [UCCCB937840365B8C72F798B019A38361] 
		, [dic1]								
		, [amcr]								
		, [dic2]								
		, [quan]								
		, [status]							
		, [response_message]					
		) 
		SELECT 
		 [year]								
		, [month]								
		, [VaAs]								
		, [acnr]								
		, [acnr_cr]							
		, [enda]								
		, [bpda]								
		, [bpnr]								
		, [DS]								
		, [amde]								
		, [U74D074944DB70225689641899DF32441] 
		, [U5E53591548A7A7DDF601A0A42217039E] 
		, [UCCCB937840365B8C72F798B019A38361] 
		, [dic1]								
		, [amcr]								
		, [dic2]								
		, [quan]	
		, ''' + @type + '''							
		, ''' + @message + ''' 	
		FROM '+ @afas_process_table) --adiha_process.dbo.batch_report_farrms_admin_07A7D948_FB8F_4B7A_8466_50D5C38D5EAB_5bc46d6161b75
END
GO