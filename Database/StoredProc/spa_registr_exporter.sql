IF OBJECT_ID(N'spa_registr_exporter', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_registr_exporter]
GO 
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: sbasnet@pioneersolutionsglobal.com
-- Create date: 2019-08-19
 
-- Params:
-- @flag CHAR(1)
-- @process_table_name  VARCHAR(100) - Process table name
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_registr_exporter]
	@flag CHAR(1),
	@xml_string VARCHAR(MAX) = NULL,
	@type VARCHAR(50) = NULL, 
	@process_id VARCHAR(50) = NULL,
	@file_name VARCHAR(MAX) = NULL,
	@file_location VARCHAR(1000) = NULL,
	@message VARCHAR(MAX) = NULL,
	@request_xml NVARCHAR(MAX) = NULL,
	@response_xml NVARCHAR(MAX) = NULL,
	@batch_process_id 	VARCHAR(100) = NULL,
	@batch_report_param 	VARCHAR(100) = NULL
AS
SET NOCOUNT ON

DECLARE @temp_process_table VARCHAR(100),
		@sql VARCHAR(MAX),
		@user_name VARCHAR(50) = dbo.FNAdbuser(),
		@desc_success VARCHAR(MAX),
		@url VARCHAR(MAX),
		@process_table VARCHAR(100),
		@export_web_service_id INT,
		@shared_path VARCHAR(300),
		@status VARCHAR(1000), 
		@error_number VARCHAR(10), 
		@error_number1 VARCHAR(10),
		@result NVARCHAR(1024),
		@full_file_path VARCHAR(200)

SELECT @export_web_service_id = id FROM export_web_service
WHERE handler_class_name = 'RegisTrExporter'

IF @flag IN ('r', 't')
BEGIN
		IF OBJECT_ID('tempdb..#temp_web_request_param') IS NOT NULL
			DROP TABLE #temp_web_request_param
		CREATE TABLE #temp_web_request_param(
			[Generic Mapping Values ID] NVARCHAR(1000),
			[Handler Class Name] NVARCHAR(1000)
		)
		DECLARE @column_count INT,
				@counter INT = 1,
				@alter_string VARCHAR(MAX) = '',
				@column_name VARCHAR(100) = ''

		SELECT @column_count = total_columns_used
		FROM generic_mapping_header
		WHERE mapping_name = 'Web Service'

		WHILE (@counter < @column_count)
		BEGIN
			SELECT @alter_string += ' ALTER TABLE #temp_web_request_param
								   ADD ' + 'param' + CAST(@counter AS VARCHAR(10))  + ' NVARCHAR(1000)	
									'
			SET @counter += 1
		END
		EXEC(@alter_string)

		INSERT #temp_web_request_param
		EXEC spa_generic_mapping_header @flag = 'a',@mapping_name = 'Web Service', @primary_column_value = 'RegisTrExporter'

		DECLARE @xml_file_list NVARCHAR(MAX), @recover_xml NVARCHAR(MAX), @request_url VARCHAR(1000), @host_url VARCHAR(1000), @soap_action VARCHAR(1000), @outmsg VARCHAR(1000),
		@response_file_xml	NVARCHAR(MAX),@response_recover_xml	NVARCHAR(MAX)


		--SELECT * FROM #temp_web_request_param
	IF @flag = 'r'
	BEGIN
	
		SELECT @request_xml = '
			<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:reg="http://regis_tr_xml_load">
			   <soapenv:Header/>
			   <soapenv:Body>
				  <reg:send_xml>
					  <user>' + param4+ '</user>
					  <password>' + param5+ '</password>
					 <loaded_xml><![CDATA[' + @xml_string + ']]></loaded_xml>
				  </reg:send_xml>
			   </soapenv:Body>
			</soapenv:Envelope>
		'
		,@request_url = param1
		,@host_url = param2
		,@soap_action = param3 + 'send_xml'
		FROM #temp_web_request_param	
		SELECT @request_xml [request_xml], @request_url [request_url], @host_url [host_url], @soap_action [soap_action_url]
	END
	ELSE IF @flag = 't'
	BEGIN
		SET @process_id = dbo.FNAGetNewID()
		SET @process_table = 'adiha_process.dbo.registr_message_log' + @process_id
		SET @file_name = 'Registr_' + CONVERT(VARCHAR(30), GETDATE(),112) + REPLACE(CONVERT(VARCHAR(30), GETDATE(),108),':','') + '.csv'
		SELECT @shared_path = document_path FROM connection_string
		SET @full_file_path = @shared_path + '\temp_Note\' + @file_name
		--SET @process_table = 'adiha_process.dbo.registr_message_log'
		SELECT @xml_file_list =  '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:reg="http://regis_tr_xml_load" xmlns:mjd="http://MJD" xmlns:arr="http://schemas.microsoft.com/2003/10/Serialization/Arrays">
					   <soapenv:Header/>
					   <soapenv:Body>
						  <reg:get_xml_list>
							 <user>' + param4+ '</user>
							 <password>' + param5+ '</password>
							 <xml_date>
								<!--Optional:-->
								<mjd:dateValue>' + CAST(dbo.FNAConvertToMJD(GETDATE()) AS VARCHAR(10)) + '</mjd:dateValue>
							 </xml_date>
							 <xml_list>
								<!--Zero or more repetitions:-->
								<arr:string></arr:string>
							 </xml_list>
						  </reg:get_xml_list>
					   </soapenv:Body>
					</soapenv:Envelope>',
					@recover_xml = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:reg="http://regis_tr_xml_load" xmlns:mjd="http://MJD" xmlns:arr="http://schemas.microsoft.com/2003/10/Serialization/Arrays">
					   <soapenv:Header/>
					   <soapenv:Body>
						  <reg:recover_xmls>
							 <user>' + param4+ '</user>
							 <password>' + param5+ '</password>
							 <xml_date>
								<!--Optional:-->
								<mjd:dateValue>' + CAST(dbo.FNAConvertToMJD(GETDATE()) AS VARCHAR(10)) + '</mjd:dateValue>
							 </xml_date>
							 <xmls>
								<arr:string></arr:string>
							 </xmls>
						  </reg:recover_xmls>
					   </soapenv:Body>
					</soapenv:Envelope>
					'
					,@request_url = param1
					,@host_url = param2
					,@soap_action = param3
		FROM 
		#temp_web_request_param

		--SELECT @process_table,@xml_file_list,@recover_xml,@request_url,@host_url,@soap_action,@outmsg,@response_file_xml,@response_recover_xml
		EXEC  spa_generate_registr_log @process_table = @process_table,@xml_file_list = @xml_file_list, @recover_xml = @recover_xml, @request_url = @request_url, @host_url = @host_url, @soap_action = @soap_action,@outmsg = @outmsg OUTPUT, @response_file_xml = @response_file_xml OUTPUT, @response_recover_xml = @response_recover_xml OUTPUT

		SELECT @error_number1 = RIGHT(@outmsg,LEN(@outmsg) - CHARINDEX(':',@outmsg))
		SELECT @outmsg = LEFT(@outmsg,CHARINDEX(':',@outmsg) - 1)
		SELECT @error_number = RIGHT(@outmsg,LEN(@outmsg) - CHARINDEX(',',@outmsg))
		SELECT @status = LEFT(@outmsg,CHARINDEX(',',@outmsg) - 1)
		--SELECT @outmsg,@error_number1,@status,@error_number
		IF @status = 'Success'
		BEGIN
			EXEC spa_export_to_csv @process_table, @full_file_path, 'y', ',', 'n','y','n','n',@result OUTPUT, '.'

			SET @sql = '
			INSERT INTO source_emir_audit([status],error_code,error_description,message_received_timestamp,message_id,uti_id,trade_id,source_file_name)
			SELECT temp.tradeType, temp.reasonCode, temp.errorDescription,temp.creationTimestamp,temp.messageId,temp.inReplyTo,se.deal_id,temp.[fileName]
			FROM ' + @process_table + ' temp
			LEFT JOIN source_emir se
				ON CAST(se.source_emir_id AS VARCHAR(10)) = LEFT(temp.inReplyTo,CHARINDEX(''_'',temp.inReplyTo) - 1)
			'
		EXEC(@sql)	
			
		SET @sql = 'DECLARE @process_id VARCHAR(MAX) = ''' + @process_id + '''
					DECLARE @user_name VARCHAR(50) = ''' + @user_name + '''
					DECLARE @url VARCHAR(MAX)
					DECLARE @desc_success VARCHAR(MAX)= ''Error.''
					DECLARE @message VARCHAR(MAX),	
							@email_description NVARCHAR(MAX)

					IF EXISTS(SELECT 1 FROM ' + @process_table + ' temp
								WHERE temp.tradeType = ''MessageRejected''
						
					)
					BEGIN
						INSERT INTO source_system_data_import_status (process_id, code, module, source, type, description)
						SELECT @process_id, temp.tradeType, ''RegisTR Interface'', ''RegisTR Interface'', ''Error'', temp.errorDescription
						FROM ' + @process_table + ' temp
						WHERE temp.tradeType = ''MessageRejected''
						SELECT @url = ''./spa_html.php?__user_name__='' + @user_name + ''&spa=exec spa_get_import_process_status '''''' + @process_id + '''''',''''''+@user_name+''''''''
						SELECT @desc_success = ''Feedback captured with error. <a target="_blank" href="'' + @url + ''">Click here.</a>''
					END
					ELSE
					BEGIN
						SET @desc_success = ''Feedback  captured successfully. Please <a target="_blank" href="../../adiha.php.scripts/force_download.php?path=dev/shared_docs/temp_Note/''''' + @file_name + '''''"><b>Click Here</b></a> to download the file.<br>''
						+  ''<b>Response :</b> '' + ISNULL(NULLIF(@message,''''),''Success'')
					END

					INSERT INTO message_board(user_login_id, source, [description], url_desc, url, [type], job_name, as_of_date, process_id, process_type)
					SELECT DISTINCT au.user_login_id, ''RegisTR'' , ISNULL(@desc_success, ''Description is null''), NULL, NULL, ''s'',NULL, NULL,@process_id,NULL
					FROM dbo.application_role_user aru
					INNER JOIN dbo.application_security_role asr ON aru.role_id = asr.role_id 
					INNER JOIN dbo.application_users au ON aru.user_login_id = au.user_login_id
					WHERE (au.user_active = ''y'') AND (asr.role_type_value_id = 22) AND au.user_emal_add IS NOT NULL
					GROUP BY au.user_login_id, au.user_emal_add	

					SELECT @email_description = STUFF((SELECT '' <br>'' +  ''<b>Message ID:</b> '' + messageID + '' | <b>In Reply To:</b> '' + inReplyTo + '' | <b>Status:</b> '' + tradeType + '' | <b>Error Description:</b> '' + errorDescription + '''' FROM ' + @process_table + '
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
					SELECT ''RegisTr Log'',
						''Dear <b>'' + MAX(au.user_l_name) + ''</b><br>
						 Feedback Response has been captured. Please check the Summary Report below:<br><br>
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

			'						
EXEC(@sql)
		END
		INSERT INTO remote_service_response_log(response_status,process_id,response_msg_detail,request_msg_detail,export_web_service_id)
		SELECT @status,@process_id,@response_file_xml,@xml_file_list, @export_web_service_id UNION
		SELECT @status,@process_id,@response_recover_xml,@recover_xml, @export_web_service_id
		
		IF @batch_process_id IS NOT NULL
		BEGIN
			UPDATE message_board
			SET    [description] = 'Batch process completed.',
				   is_read = 0,
				   update_ts = GETDATE()
			WHERE process_id = @batch_process_id	
		END
		
	END

END

IF @flag = 's'
BEGIN
	--SELECT @process_id = dbo.FNAGETNEWID() 
	--SET @temp_process_table = 'adiha_process.dbo.source_emir_' + @process_id
	--SET @sql = 'SELECT TOP 1 *
	--			INTO ' + @temp_process_table + '
	--			FROM source_emir
	--			ORDER BY source_emir_id DESC
	--			'
	--EXEC(@sql)
	--SELECT @temp_process_table [process_table]
	SET @process_table = dbo.FNAProcessTableName('batch_report', NULL, @process_id)
	SET @sql = 'IF COL_LENGTH('''+ @process_table +''', ''message_id'') IS NULL
			BEGIN
				ALTER TABLE ' + @process_table + ' ADD message_id VARCHAR(300) NULL
			END'
	EXEC(@sql)
	
	SET @sql = 'UPDATE temp
			SET temp.message_id = IIF(se.source_emir_id IS NULL,dbo.FNAGETNEWID(),CAST(se.source_emir_id AS VARCHAR(10)) + ''_'' + FORMAT(SYSDATETIME(), ''yyyyMMddHHmmssffff'') )
		  FROM ' + @process_table + ' temp
		  LEFT JOIN source_emir se
			ON se.trade_id = temp.[Trade ID]
			AND se.reporting_timestamp = temp.[As of Date/Time]
		'
	EXEC(@sql)
	SELECT @process_table [process_table]
END
ELSE If @flag = 'm' -- For building message
BEGIN
	IF @type = 'Success'
	BEGIN
		--SET @desc_success = 'Data has been posted successfully. Please <a target="_blank" href="../../adiha.php.scripts/force_download.php?path=dev/shared_docs/temp_Note/' + @file_name + '"><b>Click Here</b></a> to download the JSON file.'
		--					+ @message
		SET @desc_success = 'Please <a target="_blank" href="../../adiha.php.scripts/force_download.php?path=dev/shared_docs/temp_Note/' + @file_name + '"><b>Click Here</b></a> to download the XML file.<br>'
						   +  '<b>Response :</b> ' + ISNULL(NULLIF(@message,''),'Success')
		EXEC spa_message_board 'i',  @user_name , NULL, 'RegisTR' , @desc_success , '', '', 's', NULL,NULL, @process_id
		SET @message = 'Successfully posted.'
	END
	ELSE IF @type = 'Failed'
	BEGIN
		SET @desc_success = 'Please <a target="_blank" href="../../adiha.php.scripts/force_download.php?path=dev/shared_docs/temp_Note/' + @file_name + '"><b>Click Here</b></a> to download the XML file.<br>'
						   +   '<b>Response :</b> ' + @message
		INSERT INTO source_system_data_import_status (process_id, code, module, source, type, description)
		SELECT @process_id, 'Failed', 'RegisTR Interface', 'RegisTR Interface', 'Error', @desc_success

		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + '&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_name+''''
 	
		SELECT @desc_success = '<a target="_blank" href="' + @url + '">Failed to post data</a>. '
		EXEC spa_message_board 'i', @user_name,  NULL, 'RegisTR', @desc_success, '', '', 's',  NULL, NULL, @process_id
	END

		INSERT INTO email_notes
			(
				notes_subject,
				notes_text,
				send_from,
				send_to,
				send_status,
				active_flag
			)		
		SELECT 'RegisTr Log',
			@message,
			'noreply@pioneersolutionsglobal.com',
			au.user_emal_add,
			'n',
			'y'
		FROM dbo.application_role_user aru
		INNER JOIN dbo.application_security_role asr ON aru.role_id = asr.role_id 
		INNER JOIN dbo.application_users au ON aru.user_login_id = au.user_login_id
		WHERE (au.user_active = 'y') AND (asr.role_type_value_id = 22) AND au.user_emal_add IS NOT NULL
		GROUP BY au.user_login_id, au.user_emal_add

		INSERT INTO remote_service_response_log(response_status,process_id,response_msg_detail,request_msg_detail,export_web_service_id)
		SELECT @type,@process_id,@response_xml,@request_xml, @export_web_service_id
END
--IF @flag IS NOT NULL
--BEGIN
--	SELECT '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:reg="http://regis_tr_xml_load">
--		   <soapenv:Header/>
--		   <soapenv:Body>
--			  <reg:change_password>
--				 <user>USRP6650</user>
--				 <password>RegisTR01</password>
--				 <new_password>RegisTR01</new_password>
--			  </reg:change_password>
--		   </soapenv:Body>
--		</soapenv:Envelope>' [request_xml]
--END
