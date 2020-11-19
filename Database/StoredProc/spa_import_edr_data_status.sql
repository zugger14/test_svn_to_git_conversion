-- Vectren Specific Object.
IF OBJECT_ID('[dbo].[spa_import_edr_data_status]','p') IS NOT NULL
DROP PROC [dbo].[spa_import_edr_data_status]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Author : Vishwas Khanal
	Dated  : 25.Dec.2009
*/
CREATE proc [dbo].[spa_import_edr_data_status]
@process_id varchar(100),
@errorCount int,
@user_login_id varchar(100),
@msg varchar(1000),
@errorType varchar(100)='n',
@fileName varchar(100) = null,
@SuccessErrorCount varchar(100)= null
AS  
BEGIN
	/*
	@errorType :1 - SSIS Processing started. 
				2 - Error on FTP Connection


	3.1 = node "ORIScode" missing
	3.2 = node "Year" missing
	3.3 = node "Quarter" missing
	3.4 = node "UnitID" missing
	3 - "Execution Exception" 

	4 - "The file is older than the data loaded in the system"
	5 - "Failed to check the file date and time"
	6 - VB.NET Exception Error 
	7 - No source or sink found
	*/
	
	DECLARE @table VARCHAR(1000),@table_tmp VARCHAR(1000),@msg_tmp	   VARCHAR(1000),@sql		VARCHAR(1000),@success INT		,@error INT,
			@recom VARCHAR(1000),@desc		VARCHAR(1000),@desc_detail VARCHAR(1000),@url_email VARCHAR(8000),@errorcode CHAR(1),
			@url   VARCHAR(1000),@user		VARCHAR(100) 

	SELECT @user_login_id = dbo.FNAdbuser()
	SELECT @errorcode='s'
	SELECT @process_id = REPLACE(@process_id,'-','_')

	SELECT @table = 'adiha_process.dbo.Vectren_SSIS_temp_Storage'

	SELECT @table_tmp=SUBSTRING(@table,CHARINDEX('dbo.' ,@table)+4,LEN(@table))
	
	IF @SuccessErrorCount IS NULL	
	BEGIN
		IF  NOT EXISTS(SELECT 'x' FROM adiha_process.sys.tables WITH(NOLOCK) WHERE NAME = @table_tmp)
			EXEC('CREATE TABLE '+@table+' ( sno INT IDENTITY(1,1),process_id VARCHAR(1000),filename VARCHAR(100),BEmsg VARCHAR(1000),FEmsg VARCHAR(1000),recom VARCHAR(1000),create_ts DATETIME,errorType VARCHAR(2))')
		
		SELECT @msg_tmp =  
						CASE @errorType 
							--WHEN '2' THEN 'FTP connection could not be established.'
							WHEN '3.1' THEN @fileName + ' : Node "ORIScode" is missing.'
							WHEN '3.2' THEN @fileName + ' : Node "Year" is missing.'	
							WHEN '3.3' THEN @fileName + ' : Node "Quarter" is missing.'
							WHEN '3.4' THEN @fileName + ' : Node "UnitID" is missing.'
							WHEN '3'   THEN @fileName + ' : Exception on execution.'
							WHEN '4'   THEN @fileName + ' : The file is older than the data loaded in the system.'
							WHEN '5'   THEN @fileName + ' : Failed to check the file date and time.'
							WHEN '6'   THEN @fileName + ' : Exception occured while validating file date.'
							WHEN '7'   THEN @fileName + ' : No source or sink found.'
							WHEN '8'   THEN @fileName + ' : Exception occured while checking source sink.'
							--WHEN '9'   THEN @fileName + ' : The file is either damaged or in unknown format.'
							ELSE
									@fileName  +' : Successfully imported.'
						END,
				@recom = 
						CASE @errorType 
							--WHEN '2' THEN 'Check with your user name and password. or please make sure the CASE for ftp path is correct.'										
							WHEN '3.1' THEN 'Please make sure the file '''+ @fileName +''' includes ORISCode.'
							WHEN '3.2' THEN 'Please make sure the file '''+ @fileName +''' includes "Year".'
							WHEN '3.3' THEN 'Please make sure the file '''+ @fileName +''' includes "Quarter".'
							WHEN '3.4' THEN 'Please make sure the file '''+ @fileName +''' includes "UnitID".'
							WHEN '3'   THEN 'Please re-import. If it doesn''t help, contact Pioneer Solutions.'
							WHEN '4'   THEN 'Please upload the latest file or delete it from the source.'
							WHEN '5'   THEN 'Failed to check the file date and time.'
							WHEN '6'   THEN 'Please re-import. If it doesn''t help, contact Pioneer Solutions.'
							WHEN '7'   THEN 'Data may not be available. Please check with your data.'
							WHEN '8'   THEN 'Please re-import. If it doesn''t help, contact Pioneer Solutions.'
							--WHEN '9'   THEN @fileName + ' : The file is either damaged or in unknown format.'
							ELSE
								' '
						END
				IF @errorType =  '1' -- '1' indicates the process of importing has started. This need not be logged.
				BEGIN
					-- Send the 'Process strated message to the message board for all the users.
					DECLARE list_user CURSOR FOR 
										SELECT application_users.user_login_id	
												FROM dbo.application_role_user 
													INNER JOIN dbo.application_security_role 
														ON dbo.application_role_user.role_id = dbo.application_security_role.role_id 
													INNER JOIN dbo.application_users 
														ON dbo.application_role_user.user_login_id = dbo.application_users.user_login_id
										WHERE (dbo.application_users.user_active = 'y') AND (dbo.application_security_role.role_type_value_id =2) 							
										GROUP BY dbo.application_users.user_login_id,  dbo.application_users.user_emal_add

					OPEN list_user
					FETCH NEXT FROM list_user INTO 	@user

					WHILE @@FETCH_STATUS = 0
					BEGIN							
						EXEC  spa_message_board 'i', @user,NULL, 'Import.Data','Import process has been started.Please refresh the message board after a while.', '', '', @errorcode, 'Interface Adaptor',null,@process_id
						FETCH NEXT FROM list_user INTO 	@user
					END

					CLOSE list_user

					DEALLOCATE list_user
				END
				ELSE
				BEGIN													
					IF @errorType<>'2'					
						INSERT INTO adiha_process.dbo.Vectren_SSIS_temp_Storage  VALUES(@process_id,@fileName,@msg_tmp,@msg,@recom,GETDATE(),@errorType)																
				END 
		
	  END
	  ELSE	  
	  BEGIN
		SELECT @success = SUBSTRING(@SuccessErrorCount,1,CHARINDEX(',',@SuccessErrorCount)-1),
		       @error   = SUBSTRING(@SuccessErrorCount,CHARINDEX(',',@SuccessErrorCount)+1,LEN(@SuccessErrorCount))

		IF @error>0 SELECT @errorcode='e'
		
		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''

		SELECT @url_email =php_path+ '/dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''
		FROM connection_string
		
		INSERT INTO source_system_data_import_status(process_id,code,module,source,[type],[description],recommendation) 
			 SELECT @process_id,
				CASE errorType WHEN '0' THEN 'Success' ELSE  'Error' END ,
				'Import Data','EDR',CASE WHEN errorType  = '0' THEN 'NA' 
									WHEN errorType  = '3' THEN 'Technical Error' 
										ELSE 'Data Error' END
						 ,BEmsg   + CASE WHEN @errorType IN ('3','6','8') THEN '(Exception : ' +  FEmsg +')' ELSE '' END  ,recom
			   FROM adiha_process.dbo.Vectren_SSIS_temp_Storage
					WHERE [filename] is not null
					AND process_id = @process_id

		IF @success + @error = 0 
			SELECT @desc = 'No files match found for import.'
			ELSE
				SELECT @desc = '<a target="_blank" href="' + @url + '">'
								+'Import completed '+CASE WHEN @error<1 THEN 'successfully' ELSE '' END +'for ' +(CAST (@success+@error AS VARCHAR)) +' files.'
								+ CASE WHEN @error>0 THEN
								'ERRORS found in ' + CAST(@error AS VARCHAR)+' files.' ELSE '' END
					   +'</a>'	
							
		EXEC spa_compliance_workflow 116,NULL,NULL,NULL,@errorcode,@desc
		/*
		-- On error send the message to the message board and also send the mail to the subscribed users.
		IF @error>0
		BEGIN		
				SET @desc_detail=''
				
				EXEC spa_interface_Adapter_email @process_id,1,@desc,@desc_detail,@url_email

				RETURN			
		 END		
		 ELSE
		 BEGIN
			-- On Success send it to the message board alone.
			DECLARE list_user CURSOR FOR 
					SELECT application_users.user_login_id	
							FROM dbo.application_role_user 
								INNER JOIN dbo.application_security_role 
									ON dbo.application_role_user.role_id = dbo.application_security_role.role_id 
								INNER JOIN dbo.application_users 
									ON dbo.application_role_user.user_login_id = dbo.application_users.user_login_id
					WHERE (dbo.application_users.user_active = 'y') AND (dbo.application_security_role.role_type_value_id =2) 							
					GROUP BY dbo.application_users.user_login_id,  dbo.application_users.user_emal_add

			OPEN list_user

			FETCH NEXT FROM list_user INTO 	@user

				WHILE @@FETCH_STATUS = 0
				BEGIN							
					EXEC  spa_message_board 'i', @user,NULL, 'Import.Data',@desc, '', '', @errorcode, 'Interface Adaptor',null,@process_id
					FETCH NEXT FROM list_user INTO 	@user
				END

			CLOSE list_user

			DEALLOCATE list_user

		 END*/
	  END
	  
END-- End of Procedure.	