/*
* CMA data Import log into Import Status table and messageBoard update
*/
IF OBJECT_ID('spa_import_cma_data_status','p') IS NOT NULL
DROP PROCEDURE [dbo].[spa_import_cma_data_status]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_import_cma_data_status]
	@flag CHAR(1) = NULL,
	@process_id VARCHAR(100),
	@temp_table_name VARCHAR(500) = '',
	@as_of_date VARCHAR(32) = NULL,
	@table_id VARCHAR(50) = '',
	@request_status_code TINYINT = NULL,
	@user_login_id VARCHAR(128) = NULL,
	@request_id INT = NULL
AS
BEGIN
	
	
	DECLARE @q VARCHAR(1500)
	DECLARE @updateStatus VARCHAR(1500)

	IF @user_login_id IS NULL
		SELECT @user_login_id = dbo.FNAdbuser()
	
	/*
	* update source_system_data_import_status table for each file	
	*/
	IF @flag = 'i'
		BEGIN
			
			--output error files
			SELECT  ssdisd.[source] FROM source_system_data_import_status_detail ssdisd
			WHERE ssdisd.process_id = @process_id
				AND NOT EXISTS (SELECT 1 FROM source_system_data_import_status WHERE process_id = @process_id
								AND [source] = ssdisd.[source] AND code = 'Error')
			GROUP BY ssdisd.process_id, ssdisd.[source]

			INSERT INTO source_system_data_import_status(process_id, code, module, [source], [type], [description], recommendation) 
			SELECT ssdisd.process_id, 'Error', 'CMA Price Curve', ssdisd.[source], 'CMA Price Curve', 'Error for curve ' + i.key_value + ': ' + ' Data Error', 'Please Check your data.'
			FROM source_system_data_import_status_detail ssdisd
			LEFT JOIN import_data_request_status_log i ON i.data_file_name = ssdisd.source --to retrieve curve id
			WHERE ssdisd.process_id = @process_id
				AND NOT EXISTS (SELECT 1 FROM source_system_data_import_status WHERE process_id = @process_id
								AND [source] = ssdisd.[source] AND code = 'Error')
			GROUP BY ssdisd.process_id, ssdisd.[source], i.key_value
			
			SET @q = 'INSERT INTO source_system_data_import_status(process_id, code, module, source, [type], [description], recommendation) 
					  SELECT ''' + @process_id + ''', CASE WHEN  i.data_update_status = ''Warning'' Then ''Warning'' WHEN i.data_update_status = ''Error'' OR i.data_update_status IS NULL OR i.response_status = ''Error'' Then ''Error'' ELSE ''Success'' END,
					  ''CMA Price Curve'', i.data_file_name, ''CMA Price Curve'',  
					  CASE 
						  WHEN i.data_update_status = ''Error'' OR i.data_update_status = ''Warning''  OR i.response_status=''Error'' THEN
						  	''Error for curve '' + i.key_value + '': '' + i.description 
						  WHEN i.data_file_name IS NULL THEN 
						  	''Data Xml file does not exist for curve '' + i.key_value 
						  ELSE
							 '' Import successful for Curve '' + i.key_value + '' for as of date '' + CAST(i.as_of_date AS VARCHAR) 
					  END [description], ''N/A''
					  FROM import_data_request_status_log i 
					  LEFT JOIN source_system_data_import_status_detail ssdisd ON i.data_file_name = ssdisd.source
						AND ssdisd.process_id = i.process_id
					  WHERE ssdisd.process_id IS NULL AND i.process_id = '''+ @process_id + ''' AND i.module_type = '''+ @table_id 
					  + ''' GROUP BY key_value, i.as_of_date, i.data_file_name, i.data_update_status, i.response_status, i.description'
			exec spa_print @q
			EXEC (@q)		
			  			
		END
		-- @temp_table_name +' a
	/*
	* update messageboard	
	*/
	ELSE IF @flag = 'm'
	BEGIN
		DECLARE @count INT
		DECLARE @elapsed_sec INT, @elapse_sec_text VARCHAR(150)
		DECLARE @errorcode CHAR(1), @url VARCHAR(512), @desc VARCHAR(1000)

		SET @errorcode='s'
		SELECT @count=COUNT(*) FROM source_system_data_import_status WHERE process_id=@process_id AND [code] = 'Warning'
		  IF @count > 0
				SET @errorcode = 'w'

		SELECT @count=COUNT(*) FROM source_system_data_import_status WHERE process_id=@process_id AND [code] = 'Error'
		  IF @count > 0
				SET @errorcode = 'e'

      SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''

	  SELECT @elapsed_sec = DATEDIFF(second, create_ts, GETDATE()) FROM import_data_files_audit idfa WHERE idfa.process_id = @process_id
	  --SET @elapse_sec_text = convert(char(8),dateadd(s, @elapsed_sec, 0),108) -- hh:mm:ss format
	  SET @elapse_sec_text = CAST(CAST(@elapsed_sec/60 AS INT) AS VARCHAR) + ' Mins ' + CAST(@elapsed_sec - CAST(@elapsed_sec/60 AS INT) * 60 AS VARCHAR) + ' Secs'
	  	
      SELECT @desc = '<a target="_blank" href="' + @url + '">' 
                      + CASE WHEN @as_of_date = '' THEN 'Price Import from CMA <span style="color:#e73a3a;">(Warning)</span>' 
						ELSE 'Price Import from CMA for as of date:'+ dbo.FNAUserDateFormat(@as_of_date, @user_login_id )
							  + CASE WHEN (@errorcode = 'e') THEN ' <span style="color:#e73a3a;">(ERRORS found)</span>' 
									 WHEN (@errorcode = 'w') THEN ' <span style="color:#e73a3a;">(Warning)</span>' ELSE '' END
						END + '.</a>' + ' [Elapse time: ' + @elapse_sec_text + ']'
						
      EXEC  spa_message_board 'u', @user_login_id,NULL, 'CMA Import Data',@desc, '', '', @errorcode, NULL, NULL ,@process_id, DEFAULT, DEFAULT, DEFAULT, 'y'

	  --audit table log update total execution time
	  EXEC spa_import_data_files_audit
			@flag = 'u',
			@process_id = @process_id, 
			@status = @errorcode,
			@elapsed_time = @elapsed_sec
	
	END
	/* update msgBoard for request
	*/
	
	ELSE IF @flag = 'r'
	BEGIN
		DECLARE @msg VARCHAR(512)--, @job_name VARCHAR(256)
		SET @msg = ''
		--SET @job_name = 'CmaRequest_' + ISNULL(@process_id ,dbo.FNAGetNewID())
		
		--SELECT @datetime = replace(convert(varchar, getdate(),111),'/','') + '_' +
		--		   replace(convert(varchar, getdate(),108),':','')
		
		IF @request_status_code = 1
		BEGIN
			SET @msg = 'Request is generated in request folder for as of date :' + @as_of_date + '  Request Id:' + cast(@request_id AS VARCHAR)
		END
		ELSE IF @request_status_code = 0
		BEGIN
			--SET @msg = '<span style="color:#e73a3a;">Request for as of date :' + @as_of_date + ' is already processed</span>'
			SET @msg = 'Request is Regenerated in request folder for as of date :' + @as_of_date + '  Request Id:' + cast(@request_id AS VARCHAR)
		END
		ELSE
			SET @msg = '<span style="color:#e73a3a;">Invalid status code</span>'

	EXEC spa_message_board  'u', @user_login_id, NULL, 'CMA_Request has been processed',
		@msg, '','', '', NULL , NULL, @process_id, DEFAULT, DEFAULT, DEFAULT,'y'
	
	END
		
	  
END
