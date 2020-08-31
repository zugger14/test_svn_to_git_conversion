
IF OBJECT_ID(N'[dbo].[spa_west_power_emailnotes_handler]', N'P') IS NOT NULL

/****** Object:  StoredProcedure [dbo].[spa_west_power_emailnotes_handler]    Script Date: 10/20/2014 9:28:44 AM ******/
DROP PROCEDURE [dbo].[spa_west_power_emailnotes_handler]
GO

/****** Object:  StoredProcedure [dbo].[spa_west_power_emailnotes_handler]    Script Date: 10/20/2014 9:28:49 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- ===========================================================================================================
-- Author: ssingh@pioneersolutionsglobal.com
-- Create date: 2012-06-22
-- Description: insert into email_notes table
--	Params:
--@flag 'i' : operation flag
--@role_type_value_id : role type of application user to whom the email  notifications are to be sent.

-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_west_power_emailnotes_handler]
@flag CHAR(1),
@role_type_value_id INT = 2,
@process_id VARCHAR(100) = NULL,
@user_login_id VARCHAR(50) = NULL,
@file_name VARCHAR(255) = ''
AS 
/*------------------------------------------------TEST SCRIPT-------------------------------------------------*/
/*
DECLARE @flag CHAR(1),
@role_type_value_id INT  
SET @flag ='i' 
SET @role_type_value_id =2

--*/
/*----------------------------------------------------------------------------------------------------------------*/
BEGIN
		DECLARE @template_params VARCHAR(5000) = ''
		DECLARE @user VARCHAR(100) = dbo.FNADBuser()	
		 
	IF @flag ='i'
	BEGIN 
		--DECLARE @user VARCHAR(100)
		--DECLARE @desc VARCHAR(1000)
				
		--		SELECT @user = dbo.FNADBuser()	
		--		SELECT @desc = 'Price Import for LADWP -West Power completed for as of date:' + dbo.FNAUserDateFormat(GETDATE(), @user) + 
		--							' (ERRORS found)'	
										
		--		INSERT INTO email_notes(
		--		[internal_type_value_id], 
		--		[category_value_id],
		--		[notes_object_id],
		--		[notes_object_name],
		--		[send_status],
		--		[active_flag], 
		--		[notes_subject],  
		--		[notes_text],  
		--		[send_from],  
		--		[send_to],  
		--		[attachment_file_name]  )

		--		SELECT DISTINCT
		--		3,
		--		4,
		--		1,
		--		'',
		--		'n',
		--		'y',
		--		'CRITICAL:' + @desc ,
		--		@desc,
		--		'noreply@pioneersolutionsglobal.com',
		--		user_emal_add,
		--		NULL
		--		FROM dbo.application_role_user 
		--		INNER JOIN dbo.application_security_role ON dbo.application_role_user.role_id = dbo.application_security_role.role_id     
		--		INNER JOIN dbo.application_users ON dbo.application_role_user.user_login_id = dbo.application_users.user_login_id    
		--		WHERE (dbo.application_users.user_active = 'y') AND (dbo.application_security_role.role_type_value_id = @role_type_value_id) 
		--		AND user_emal_add IS NOT NULL
		--		GROUP BY dbo.application_users.user_login_id,dbo.application_users.user_emal_add 
		

		
		--replace template fields
		SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<TRM_IMPORT_SOURCE>', 'West Power')
		SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<TRM_IMPORT_AS_OF_DATE>', dbo.FNAUserDateFormat(GETDATE(), @user))
		SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<TRM_IMPORT_SOURCE_MSG>', 'Data has not been imported successfully.')

		--call spa_email_notes
		
		EXEC spa_email_notes
			@flag = 'b',
			@role_type_value_id = @role_type_value_id,
			@email_module_type_value_id = 17805,
			@send_status = 'n',
			@active_flag = 'y',
			@template_params = @template_params,
			@internal_type_value_id = 3,
			@category_value_id = 4,
			@notes_object_id = 1,
			@notes_object_name = NULL
		END 
		
	IF @flag ='j'
	BEGIN 

		IF NOT EXISTS(SELECT 1 FROM source_system_data_import_status WHERE process_id = @process_id AND source = 'ForwardPrice')
		BEGIN
			INSERT  INTO  source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
			SELECT  @process_id,'Error','Import Data','ForwardPrice','Data Error','Invalid Excel Sheet','Please verify data'
			
					--replace template fields
			SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<TRM_IMPORT_SOURCE>', 'LADWP Forward Price')
			SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<TRM_IMPORT_AS_OF_DATE>', dbo.FNAUserDateFormat(GETDATE(), @user))
			SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<TRM_IMPORT_SOURCE_MSG>', 'Data has not been imported successfully (Errors Found).')

			--call spa_email_notes
		
			EXEC spa_email_notes
				@flag = 'b',
				@role_type_value_id = @role_type_value_id,
				@email_module_type_value_id = 17805,
				@send_status = 'n',
				@active_flag = 'y',
				@template_params = @template_params,
				@internal_type_value_id = 3,
				@category_value_id = 4,
				@notes_object_id = 1,
				@notes_object_name = NULL
			END 
			
			
		END
		
		INSERT  INTO  source_system_data_import_status_detail(process_id,source,type,[description]) 
		SELECT  @process_id,'ForwardPrice','Data Error','File: ' + @file_name + ' is Invalid'
						
				
	
END 
