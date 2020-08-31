IF OBJECT_ID(N'spa_nordpool_exporter', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_nordpool_exporter]
GO 
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: sbasnet@pioneersolutionsglobal.com
-- Create date: 2019-08-08
 
-- Params:
-- @flag CHAR(1)
-- @process_table_name  VARCHAR(100) - Process table name
-- ===========================================================================================================

/**   
    Created for exporting remit report
    Parameters
    @flag:   Operational flag
			 'm' Insert message in message board
    @process_table_name: Process table name
	@tableNameorQuery: Table or query. Added for debugging cases
	@process_id: Process Id
	@file_name: Generated file name
    @file_location: Location of the generated file
	@message: Message to be inserted in message board
	@type: Success or fail

*/


CREATE PROCEDURE [dbo].[spa_nordpool_exporter]
	@flag CHAR(1),
	@process_table_name VARCHAR(500) = NULL,
	@tableNameorQuery VARCHAR(1000) = NULL, --added for testing purpose
	@remit_process_id VARCHAR(50) = NULL,
	@file_name VARCHAR(100) = NULL,
	@file_location VARCHAR(1000) = NULL,
	@message VARCHAR(MAX) = NULL,
	@type VARCHAR(50) = NULL,
	@report_id VARCHAR(MAX) = NULL,
	@request_xml NVARCHAR(MAX) = NULL,
	@response_xml NVARCHAR(MAX) = NULL,
	@report_type INT = NULL,
	@batch_process_id 	VARCHAR(100) = NULL,
	@batch_report_param 	VARCHAR(100) = NULL
AS
SET NOCOUNT ON

DECLARE @user_name VARCHAR(50) = dbo.FNAdbuser()
		,@desc_success VARCHAR(MAX)
		,@url VARCHAR(MAX)
		,@export_web_service_id INT
		,@process_table VARCHAR(100)
		,@report_ids VARCHAR(MAX)
		,@response_status VARCHAR(100)
		,@outmsg VARCHAR(1000)
		,@shared_path VARCHAR(300)
		,@full_file_path VARCHAR(200)
		,@result NVARCHAR(1024)
		,@sql VARCHAR(MAX)
		,@process_id VARCHAR(50)
		,@phy_remit_table_name VARCHAR(100)

SELECT @export_web_service_id = id FROM export_web_service
WHERE handler_class_name = 'NordpoolExporter'
SET @process_id = dbo.FNAGetNewID()


IF (@report_type = 39400) 
	SET @phy_remit_table_name = 'source_remit_non_standard'
ELSE IF (@report_type IN(39401, 39405)) 
	SET @phy_remit_table_name = 'source_remit_standard'

IF @flag = 'm' -- For building message
BEGIN
	IF @type = 'Success'
	BEGIN
		SET @message =  '<b>Response :</b> ' + @message
		SET @desc_success = 'Please <a target="_blank" href="../../adiha.php.scripts/force_download.php?path=dev/shared_docs/temp_Note/' + @file_name + '"><b>Click Here</b></a> to download the request XML file.<br>'
						   +  @message
		EXEC spa_message_board 'i',  @user_name , NULL, 'Nordpool' , @desc_success , '', '', 's', NULL,NULL, @process_id
		SET @response_status = 'UploadToAcerInitiated'
		EXEC('UPDATE ' + @phy_remit_table_name + ' SET acer_submission_status = 39501 WHERE process_id = ''' + @remit_process_id + '''')
	END
	ELSE IF @type = 'Failed'
	BEGIN
		SET @desc_success = 'Please <a target="_blank" href="../../adiha.php.scripts/force_download.php?path=dev/shared_docs/temp_Note/' + @file_name + '"><b>Click Here</b></a> to download the request XML file.<br>'
						   +  @message
		INSERT INTO source_system_data_import_status (process_id, code, module, source, type, description)
		SELECT @process_id, 'Failed', 'Remit Interface', 'Remit Interface', 'Error', @desc_success

		SELECT @url = './spa_html.php?__user_name__=' + @user_name + '&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_name+''''
 	
		SELECT @desc_success = '<a target="_blank" href="' + @url + '">Failed to submit report</a>. '
		EXEC spa_message_board 'i', @user_name,  NULL, 'Remit', @desc_success, '', '', 's',  NULL, NULL, @process_id
		SET @response_status = @message
		EXEC('UPDATE ' + @phy_remit_table_name + ' SET acer_submission_status = 39503 WHERE process_id = ''' + @remit_process_id + '''')
	END	

	INSERT INTO remote_service_response_log(response_status,response_message, process_id,request_identifier,request_msg_detail,response_msg_detail,export_web_service_id)
	SELECT @type, @response_status, @remit_process_id, @report_id, @request_xml, @response_xml, @export_web_service_id

END

ELSE IF @flag = 't'
BEGIN
	SET @process_table = 'adiha_process.dbo.nordpool_response_' + @process_id
	--SET @process_table = 'adiha_process.dbo.temp_nordpool_response'
	SET @file_name = 'Remit_Feedback_' + CONVERT(VARCHAR(30), GETDATE(),112) + REPLACE(CONVERT(VARCHAR(30), GETDATE(),108),':','') + '.csv'
		SELECT @shared_path = document_path FROM connection_string
	SET @full_file_path = @shared_path + '\temp_Note\' + @file_name
	SELECT @report_ids = STUFF((SELECT DISTINCT ',' +  request_identifier 
							FROM remote_service_response_log
							WHERE export_web_service_id = @export_web_service_id
							AND response_message = 'UploadToAcerInitiated'
											FOR XML PATH('')), 1, 1, '') 
	--SET @report_ids = '57736393-d1cd-4a29-ac54-f6c6c9e44990,44f82bd5-a59b-4c35-a33d-f8078339a526,756dfc70-0e05-4d97-91db-8c7b3bebbcf8,sadfasdfasdfasfdsadsaf,7bd1b95d-a077-4635-950b-76ad77770531'
	IF NULLIF(@report_ids,'') IS NOT NULL
	BEGIN
		EXEC  spa_generate_nordpool_log @report_ids = @report_ids,@process_table = @process_table, @outmsg = @outmsg OUTPUT

		IF @outmsg = 'Success'
		BEGIN
			EXEC spa_export_to_csv @process_table, @full_file_path, 'y', ',', 'n','y','n','n',@result OUTPUT

			SET @sql = 'DECLARE @process_id VARCHAR(MAX) = ''' + @process_id + '''
						DECLARE @user_name VARCHAR(50) = ''' + @user_name + '''
						DECLARE @url VARCHAR(MAX)
						DECLARE @desc_success VARCHAR(MAX)= ''Error.''
						DECLARE @message VARCHAR(MAX),	
								@email_description NVARCHAR(MAX)

						IF EXISTS(SELECT 1 FROM ' + @process_table + ')
						BEGIN
							IF EXISTS(SELECT 1 FROM ' + @process_table + ' temp
									WHERE temp.status = ''Rejected_Content''
							)
							BEGIN
								INSERT INTO source_system_data_import_status (process_id, code, module, source, type, description)
								SELECT @process_id, temp.status, ''Remit Interface'', ''Remit Interface'', ''Error'', temp.errorDescription + ''. '' + temp.errorDetails
								FROM ' + @process_table + ' temp
								WHERE temp.status = ''Rejected_Content''
								SELECT @url = ''./spa_html.php?__user_name__='' + @user_name + ''&spa=exec spa_get_import_process_status '''''' + @process_id + '''''',''''''+@user_name+''''''''
								SELECT @desc_success = ''Feedback captured with error. <a target="_blank" href="'' + @url + ''">Click here.</a>''
							END
							ELSE
							BEGIN
								SET @desc_success = ''Feedback  captured successfully. Please <a target="_blank" href="../../adiha.php.scripts/force_download.php?path=dev/shared_docs/temp_Note/' + @file_name + '"><b>Click Here</b></a> to download the file.<br>''
								+  ''<b>Response :</b> '' + ISNULL(NULLIF(@message,''''),''Success'')
							END

							INSERT INTO message_board(user_login_id, source, [description], url_desc, url, [type], job_name, as_of_date, process_id, process_type)
							SELECT DISTINCT au.user_login_id, ''Remit'' , ISNULL(@desc_success, ''Description is null''), NULL, NULL, ''s'',NULL, NULL,@process_id,NULL
							FROM dbo.application_role_user aru
							INNER JOIN dbo.application_security_role asr ON aru.role_id = asr.role_id 
							INNER JOIN dbo.application_users au ON aru.user_login_id = au.user_login_id
							WHERE (au.user_active = ''y'') AND (asr.role_type_value_id = 22) AND au.user_emal_add IS NOT NULL
							GROUP BY au.user_login_id, au.user_emal_add	

							SELECT @email_description = STUFF((SELECT '' <br>'' +  ''<b>Report ID:</b> '' + reportID + '' | <b>Status:</b> '' + status + '' | <b>Error Code:</b> '' + errorCode + '' | <b>Error Description:</b> '' + errorDescription + '' | <b>Error Details:</b> '' + errorDetails + '''' FROM ' + @process_table + '
																		FOR XML PATH(''''), TYPE).value(''.[1]'', ''VARCHAR(8000)''),
															1, 1, '''' )
							INSERT INTO email_notes
								(
									notes_subject,
									notes_text,
									send_from,
									send_to,
									send_status,
									active_flag,
									notes_attachment
								)		
							SELECT ''Remit Feedback'',
								''Dear <b>'' + MAX(au.user_l_name) + ''</b><br>
								 Remit Feedback Response has been captured. Please check the Summary Report below:<br><br>
								 <b><u>Description</u></b><br>'' +
								 @email_description,
								''noreply@pioneersolutionsglobal.com'',
								au.user_emal_add,
								''n'',
								''y'',
								''temp_Note/'+ @file_name +'''
							FROM dbo.application_role_user aru
							INNER JOIN dbo.application_security_role asr ON aru.role_id = asr.role_id 
							INNER JOIN dbo.application_users au ON aru.user_login_id = au.user_login_id
							WHERE (au.user_active = ''y'') AND (asr.role_type_value_id = 22) AND au.user_emal_add IS NOT NULL
							GROUP BY au.user_login_id, au.user_emal_add
						END
				'						
			EXEC(@sql)

			SET @sql = 'INSERT INTO remote_service_response_log(response_status,response_message, process_id,request_identifier,request_msg_detail,response_msg_detail,export_web_service_id)
			SELECT DISTINCT CASE WHEN NULLIF(temp.status,'''') IS NOT NULL THEN ''Success'' ELSE ''Failed'' END
				   ,temp.status
				   ,''' + @process_id + '''
				   ,temp.reportID
				   ,temp.requestURL
				   ,temp.responseXML
				   ,''' + CAST(@export_web_service_id AS VARCHAR(10)) + '''
			FROM ' + @process_table + ' temp'
			--print @sql
			EXEC (@sql)

			SET @sql = 'UPDATE rsrl
							SET rsrl.response_message = temp.uploadStatus
						FROM ' + @process_table + ' temp
						INNER JOIN remote_service_response_log rsrl
							ON rsrl.request_identifier = temp.reportID
						WHERE rsrl.request_identifier IS NOT NULL
						  AND rsrl.response_message = ''UploadToAcerInitiated''
						  AND rsrl.export_web_service_id = ''' + CAST(@export_web_service_id AS VARCHAR(10)) + ''''
			--print @sql
			EXEC (@sql)

			IF OBJECT_ID('tempdb..#temp_source_remit') IS NOT NULL
				DROP TABLE #temp_source_remit

			CREATE TABLE #temp_source_remit(
				id INT,
				record_identifier INT,
				source_deal_header_id INT,
				deal_id VARCHAR(200),
				report_id VARCHAR(100),
				process_id VARCHAR(100),
				report_type INT
			)

			SET @sql = 'INSERT INTO #temp_source_remit(id,record_identifier,source_deal_header_id,deal_id,report_id,process_id,report_type)
			SELECT srns.id, ROW_NUMBER() OVER(PARTITION BY srns.[process_id] ORDER BY srns.[Action_type]),  srns.source_deal_header_id, srns.deal_id, rsrl.request_identifier, srns.process_id,srns.report_type
			FROM remote_service_response_log rsrl
			INNER JOIN source_remit_non_standard srns
				ON srns.process_id = rsrl.process_id
			INNER JOIN dbo.FNASPLIT(''' + @report_ids + ''','','') tbl
				ON tbl.item = rsrl.request_identifier
			WHERE rsrl.response_message IN (''ProcessingByAcerFailed'',''ProcessingByAcerCompleted'')

			INSERT INTO #temp_source_remit(id,record_identifier,source_deal_header_id,deal_id,report_id,process_id,report_type)
			SELECT srns.id, ROW_NUMBER() OVER(PARTITION BY srns.[process_id] ORDER BY srns.[Action_type]),  srns.source_deal_header_id, srns.deal_id, rsrl.request_identifier, srns.process_id,srns.report_type
			FROM remote_service_response_log rsrl
			INNER JOIN source_remit_standard srns
				ON srns.process_id = rsrl.process_id
			INNER JOIN dbo.FNASPLIT(''' + @report_ids + ''','','') tbl
				ON tbl.item = rsrl.request_identifier
			WHERE rsrl.response_message IN (''ProcessingByAcerFailed'',''ProcessingByAcerCompleted'')
			'
			EXEC(@sql)

			SET @sql = 'INSERT INTO source_remit_audit([status],[error_code],[error_description],[uti_id], [trade_id],  [type], [message_id])
						SELECT DISTINCT temp.[status], temp.[errorCode], temp.[errorDescription] + ''. '' + temp.[errorDetails], tsrns.id, tsrns.deal_id, tsrns.report_type, temp.[reportID]
						FROM ' + @process_table + ' temp
						INNER JOIN #temp_source_remit tsrns
							ON tsrns.report_id = temp.[reportID]
							AND tsrns.record_identifier = temp.[logicalRecordIdentifier]
						WHERE NULLIF(temp.uploadStatus,'''') IS NOT NULL 
						AND NULLIF(temp.[status],'''') IS NOT NULL 

						UPDATE srns
							SET srns.acer_submission_status = CASE WHEN sra.[status] = ''Accepted'' THEN 39502 ELSE 39503 END
						FROM source_remit_audit sra
						INNER JOIN source_remit_non_standard srns
							ON CAST(srns.id AS VARCHAR(20)) = sra.uti_id
						WHERE report_type = 39400

						UPDATE srns
							SET srns.acer_submission_status = CASE WHEN sra.[status] = ''Accepted'' THEN 39502 ELSE 39503 END
						FROM source_remit_audit sra
						INNER JOIN source_remit_standard srns
							ON CAST(srns.id AS VARCHAR(20)) = sra.uti_id
						WHERE report_type <> 39400
						'
			EXEC (@sql)
		END
	END
	IF @batch_process_id IS NOT NULL
	BEGIN
		UPDATE message_board
		SET    [description] = 'Batch process completed.',
				is_read = 0,
				update_ts = GETDATE()
		WHERE process_id = @batch_process_id	
	END
END


