IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_application_users]') AND type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_application_users]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	Stored Procedure that performs CRUD operations of application users

	Parameters 
	@flag : 's' Select all rows from application_users table or select row from application user table which matches given user login id
			't' Return timezone name for php of specific user
			'm' Return message refresh time for specific user
			'i' Insert new application user
			'u' Update existing application user
			'd' Delete existing application user
			'l' Lock user account
			'j' Select all user login id, first name, middle name and last name
			'v' Select all user expect current user and users which has pending batch process notifications.
			'p' Check if user has permission to alter any login
			'a' Select all users for dhtmlx grid maintain users if user login id is not null else selects only one user which matches given user login id
			'f' Select user login id with full name of users having different roles
			'w' Select user password, first name, last name and email address of specific user.
			'x' 
			'k' Identify user email address using user_login_id
			'n' Identify user login id using email address. It is used in reset password logic from website.
			'r' Change user password from website
			'e' Set/unset user as read-only. Read-only user will have only read access to menu and cannot add/delete/update any data.
			'y' Get default separator values
	@user_login_id : Login ID of the application user.
	@user_f_name : First name of application user.
	@user_m_name : Middle name of application user.
	@user_l_name : Last name of application user.
	@user_pwd : Encrypted password of application user.
	@user_title : Title of user
	@entity_id : 
	@user_address1 : Address 1 of application user
	@user_address2 : Address 2 of application user
	@user_address3 : Address 3 of application user
	@city_value_id : Value ID for city where user resides
	@state_value_id : Value ID for State where user resides
	@user_zipcode : Zipcode of application user
	@user_off_tel : Office Phone Number
	@user_main_tel : Primary Telephone Number
	@user_pager_tel : Pager Number
	@user_mobile_tel : Mobile Number
	@user_fax_tel : Fax Number
	@user_emal_add : Email Address of the user.
	@user_db_pwd : User password for SQL login
	@message_refresh_time : Message refresh time setting of the user
	@region_id : ID for user's region
	@user_active : User account status which can be either active or inactive.
	@temp_pwd : 'y' if user password is temporary 'n' if not
	@expire_date : Password expiry date
	@lock_account : 'y' if user account is locked else 'n'
	@reports_to :
	@user_mode_create : 
	@timezone_id : ID for user's timezone
	@process_id : Process ID 
	@menu_type_role_id :
	@pwd_raw : Unencrypted user password
	@user_role : User role ID
	@application_users_id : Primary Identity Key of application users table
	@user : Comma separated user IDs
	@role : Comma separated role IDs
	@include_exclude :
	@cloud_mode : '1' if SaaS mode is on else '0'
	@theme_value_id : Value ID for user preferred theme
	@db_server_name : Database servername for application user
	@new_pwd : Encrypted new password for user
	@pwd_expiry_days: Number of password expiry days
	@del_application_users_id : List of application user IDs to delete
	@auth_token : Bearer token for making authorized API requests
	@read_only_user : User having read only privilege in the application. User will not be able to add/update/delete any data. Values: 'y' if user is read-only.
	@language: Language of the application, Default English
	@ixp_rules_id: Import rule id. It is used in Import Notification.
	@decimal_separator : Decimal Separator for number format
	@group_separator : Group Separator for number format
	*/

CREATE PROC [dbo].[spa_application_users]
	@flag CHAR(1), --'t' => get logged ON user's timezone
	@user_login_id NVARCHAR(MAX) = NULL ,
	@user_f_name NVARCHAR(50) = NULL ,
	@user_m_name NVARCHAR(50) = NULL ,
	@user_l_name NVARCHAR(100) = NULL ,
	@user_pwd VARCHAR(50) = NULL ,
	@user_title NVARCHAR(50) = NULL ,
	@entity_id INT = NULL ,
	@user_address1 NVARCHAR(250) = NULL ,
	@user_address2 NVARCHAR(250) = NULL ,
	@user_address3 NVARCHAR(250) = NULL ,
	@city_value_id NVARCHAR(100) = NULL ,
	@state_value_id INT = NULL ,
	@user_zipcode NVARCHAR(20) = NULL ,
	@user_off_tel VARCHAR(20) = NULL ,
	@user_main_tel VARCHAR(20) = NULL ,
	@user_pager_tel VARCHAR(20) = NULL ,
	@user_mobile_tel VARCHAR(20) = NULL ,
	@user_fax_tel VARCHAR(20) = NULL ,
	@user_emal_add VARCHAR(MAX) = NULL,
	@user_db_pwd VARCHAR(50) = NULL,
	@message_refresh_time INT = NULL,
	@region_id INT = 1,
	@user_active CHAR(1) = 'n',
	@temp_pwd CHAR(1) = 'y',
	@expire_date VARCHAR(20) = NULL,
	@lock_account VARCHAR(1) = NULL,
	@reports_to VARCHAR(50) = NULL,
	@user_mode_create VARCHAR(50) = NULL,
	@timezone_id INT = NULL,
	@process_id VARCHAR(50) = NULL,
	@menu_type_role_id INT = NULL,
	@pwd_raw VARCHAR(50) = NULL,
	@user_role INT = NULL,
	@application_users_id INT = NULL,
	@user VARCHAR(MAX) = NULL,
	@role VARCHAR(MAX) = NULL,
	@include_exclude CHAR(1) = NULL,
	@cloud_mode INT = 0,
	@theme_value_id VARCHAR(100) = NULL,
	@db_server_name VARCHAR(50) = NULL,
	@new_pwd VARCHAR(50) = NULL,
	@pwd_expiry_days INT = 90,
	@del_application_users_id VARCHAR(100) = NULL,
	@auth_token NVARCHAR(1000) = NULL,
	@read_only_user CHAR(1) = NULL,
	@language INT = 101600,
	@ixp_rules_id INT = NULL,
	@decimal_separator NVARCHAR(1) = NULL,
	@group_separator NVARCHAR(1) = NULL
AS
/*****************************Debug*****************************
DECLARE @flag CHAR(1), --'t' => get logged ON user's timezone
		@user_login_id VARCHAR(50) = NULL ,
		@user_f_name VARCHAR(50) = NULL ,
		@user_m_name VARCHAR(50) = NULL ,
		@user_l_name VARCHAR(100) = NULL ,
		@user_pwd VARCHAR(50) = NULL ,
		@user_title VARCHAR(50) = NULL ,
		@entity_id INT = NULL ,
		@user_address1 VARCHAR(250) = NULL ,
		@user_address2 VARCHAR(250) = NULL ,
		@user_address3 VARCHAR(250) = NULL ,
		@city_value_id VARCHAR(100) = NULL ,
		@state_value_id INT = NULL ,
		@user_zipcode VARCHAR(20) = NULL ,
		@user_off_tel VARCHAR(20) = NULL ,
		@user_main_tel VARCHAR(20) = NULL ,
		@user_pager_tel VARCHAR(20) = NULL ,
		@user_mobile_tel VARCHAR(20) = NULL ,
		@user_fax_tel VARCHAR(20) = NULL ,
		@user_emal_add VARCHAR(50) = NULL,
		@user_db_pwd VARCHAR(50) = NULL,
		@message_refresh_time INT = NULL,
		@region_id INT = 1,
		@user_active CHAR(1) = 'n',
		@temp_pwd CHAR(1) = 'y',
		@expire_date VARCHAR(20) = NULL,
		@lock_account VARCHAR(1) = NULL,
		@reports_to VARCHAR(50) = NULL,
		@user_mode_create VARCHAR(50) = NULL,
		@timezone_id INT = NULL,
		@process_id VARCHAR(50) = NULL,
		@menu_type_role_id INT = NULL,
		@pwd_raw VARCHAR(50) = NULL,
		@user_role INT = NULL,
		@application_users_id INT = NULL,
		@user VARCHAR(MAX) = NULL,
		@role VARCHAR(MAX) = NULL,
		@include_exclude CHAR(1) = NULL,
		@cloud_mode INT = 0,
		@theme_value_id VARCHAR(100) = NULL,
		@db_server_name VARCHAR(50) = NULL,
		@language INT = 101600,
		@decimal_separator NVARCHAR(1) = NULL,
		@group_separator NVARCHAR(1) = NULL
SELECT  @application_users_id='3222',@user_mode_create=NULL,@flag='d'
--*************************************************************/
SET NOCOUNT ON
DECLARE @sql_stmt NVARCHAR(4000)
DECLARE @database_name1 varchar(100) = DB_NAME()
DECLARE @api_url VARCHAR(200)
      , @post_data VARCHAR(MAX)
	  , @output_result NVARCHAR(MAX)
	  , @http_web_response NVARCHAR(MAX)
	  , @error_no INT
	  , @error_msg VARCHAR(100)

IF @message_refresh_time IS NOT NULL
BEGIN
	SET @message_refresh_time = @message_refresh_time * 1000
END

--SELECT all users excluding assigned
IF @flag = 's' AND @user_login_id IS NULL
BEGIN
	SELECT user_login_id AS [Login Id],
			user_f_name AS [First Name],
			user_m_name AS [Middle Name],
			user_l_name AS [Last Name],
			(user_pwd) AS [User Password],
			user_title,
			entity_id,
			user_address1,
			user_address2,
			user_address3,
			city_value_id,
			state_value_id,
			user_zipcode,
            user_off_tel,
			user_main_tel,
			user_pager_tel,
			user_mobile_tel,
			user_fax_tel,
			user_emal_add,
			create_user,
			create_ts,
			update_user,
			update_ts,
			message_refresh_time,
			region_id,
			user_active,
			expire_date AS [expire_date],
			temp_pwd,
			lock_account,
			reports_to_user_login_id,
			timezone_id
	FROM application_users
	ORDER BY user_f_name
END

ELSE IF @flag = 's' AND @user_login_id IS NOT NULL
BEGIN
	SELECT	user_login_id AS [Login Id],
			user_f_name AS [First Name],
			user_m_name AS [Middle Name],
			user_l_name AS [Last Name],
			user_pwd AS [User Password],
			user_title,
			au.entity_id,
			user_address1,
			user_address2,
			user_address3,
			city_value_id,
			state_value_id,
			user_zipcode,
			user_off_tel,
			user_main_tel,
			user_pager_tel,
			user_mobile_tel,
			user_fax_tel,
			user_emal_add,
			au.create_user,
			au.create_ts,
			au.update_user,
			au.update_ts,
			message_refresh_time,
			au.region_id,
			user_active,
			expire_date AS [expire_date],
			temp_pwd,
			lock_account,
			au.timezone_id,
			TIMEZONE_NAME_FOR_PHP,
			'theme-' + COALESCE(au.theme_value_id,avi.version_theme_name,'jomsomGreen') [default_theme],
			[date_format]
	FROM application_users au
		LEFT JOIN time_zones tz
			ON au.timezone_id = tz.timezone_id
		LEFT JOIN application_version_info avi ON 1 = 1
		LEFT JOIN region r
			ON r.region_id = au.region_id
	WHERE user_login_id = @user_login_id
END

ELSE IF @flag = 't'
BEGIN
	SELECT TIMEZONE_NAME_FOR_PHP
	FROM application_users au
		LEFT JOIN time_zones tz
			ON au.timezone_id = tz.timezone_id
	WHERE au.user_login_id = dbo.FNADBUser()

END

ELSE IF @flag = 'm'
BEGIN
	SELECT message_refresh_time
	FROM application_users
	WHERE user_login_id = @user_login_id
END

ELSE IF @flag = 'i'
BEGIN
	-- Check the number of users created
	IF EXISTS (
		SELECT 1
		FROM application_users au
		OUTER APPLY (
			SELECT total_users
			FROM application_license
		) al
		WHERE ( -- Do not count internal users with pioneer/hitachi domain.
			CHARINDEX('@pioneersolutionsglobal.com', au.user_emal_add) <= 0 AND
			CHARINDEX('@hitachi-powergrids.com', au.user_emal_add) <= 0 AND
			CHARINDEX('@us.abb.com', au.user_emal_add) <= 0
		) AND 1 = ( -- If the email address is of internal user then do not restrict.
			CASE
				WHEN CHARINDEX('@pioneersolutionsglobal.com', @user_emal_add) > 0 THEN 0
				WHEN CHARINDEX('@hitachi-powergrids.com', @user_emal_add) > 0 THEN 0
				WHEN CHARINDEX('@us.abb.com', @user_emal_add) > 0 THEN 0
				ELSE 1
			END
		)
		GROUP BY al.total_users
		HAVING COUNT(au.user_login_id) >= al.total_users
	)
	BEGIN
		EXEC spa_ErrorHandler -1,
					'Application User',
					'spa_application_User',
					'Error',
					'Number of user allocated is exceeded.',
					''
		RETURN
	END

	IF (@cloud_mode = 1)
	BEGIN
		-- Set the new user login id
		DECLARE @user_id INT, @company_code VARCHAR(64)
		SET @user_id = IDENT_CURRENT('application_users')
		SELECT @company_code = company_code FROM company_info
		SET @user_login_id = LOWER(@company_code) + '_' + CAST(@user_id + 1 AS VARCHAR(10)) -- @company_code should be converted to lower case else save button is disabled on change password screen upon first login attempt using temp password.
	END

	IF EXISTS(SELECT 1 FROM application_users WHERE user_login_id = @user_login_id)
	BEGIN
		DECLARE @err_msg varchar(100)
		SELECT @err_msg = 'This login name already exists! Please select a new login name.'
		EXEC spa_ErrorHandler -1, 'Application User',
			'spa_application_User', 'Error',
			@err_msg, ''
		RETURN
	END
	ELSE IF EXISTS (SELECT 1 FROM application_users WHERE user_emal_add = @user_emal_add AND user_login_id <> @user_login_id)
	BEGIN
		EXEC spa_ErrorHandler -1, 'Application User',
				'spa_application_User', 'Error',
				'This email ID is already in use. Please enter a different ID.', ''
		RETURN
	END
	ELSE
	BEGIN
		BEGIN TRY
			/* Inser user data on application_users table only if user email is available in adiha_cloud application user table as it may be used in another application */
			-- user insert at adiha_cloud START
			IF (@cloud_mode = 1)
			BEGIN
				SELECT @api_url = SUBSTRING(file_attachment_path, 0, CHARINDEX('/trm/', file_attachment_path)) + '/api/index.php?route=resolve-path/create-user'
				FROM connection_string

				SET @post_data = '{"user_login_id": "' + @user_login_id + '", "user_f_name": "' + @user_f_name + '", "user_l_name": "' + @user_l_name + '", "user_email_address": "' + @user_emal_add + '", "database_name": "' + @database_name1 + '", "db_server_name": "' + ISNULL(REPLACE(@db_server_name, '\', '\\'), 'NULL') + '"}'

				EXEC spa_push_notification @push_php_url = @api_url, @push_xml = @post_data, @debug_mode = 'y', @output_result = @output_result OUTPUT, @http_web_response = @http_web_response OUTPUT, @authorization_type = 'bearertoken', @access_token = @auth_token

				IF (@output_result = 'success')
				BEGIN
					IF EXISTS (
						SELECT 1
						FROM OPENJSON(@http_web_response)
							WITH (
								[message] VARCHAR(500)
							)
						WHERE [message] = 'not available'
					)
					BEGIN
						RAISERROR ('This email ID is already in use. Please enter a different ID.', 16, 1)
					END
				END
				ELSE
				BEGIN
					RAISERROR ('Please check API configuration. Could not create user in cloud database.', 16, 1)
				END
			END
			-- user insert at adiha_cloud END

			BEGIN TRAN

			INSERT INTO dbo.application_users (
				user_login_id,
				user_f_name,
				user_m_name,
				user_l_name,
				user_pwd,
				user_title,
				entity_id,
				user_address1,
				user_address2,
				user_address3,
				city_value_id,
				state_value_id,
				user_zipcode,
				user_off_tel,
				user_main_tel,
				user_pager_tel,
				user_mobile_tel,
				user_fax_tel,
				user_emal_add,
				message_refresh_time,
				region_id,
				user_active,
				temp_pwd,
				expire_date,
				lock_account,
				reports_to_user_login_id,
				timezone_id,
				menu_type_role_id,
				theme_value_id,
				[language],
				decimal_separator,
				group_separator
			)
			VALUES (
				@user_login_id,
				@user_f_name,
				@user_m_name,
				@user_l_name,
				@user_pwd, --PHPEnc
				@user_title,
				NULLIF(@entity_id, ''),
				@user_address1,
				@user_address2,
				@user_address3,
				@city_value_id,
				NULLIF(@state_value_id, ''),
				@user_zipcode,
				@user_off_tel,
				@user_main_tel,
				@user_pager_tel,
				@user_mobile_tel,
				@user_fax_tel,
				@user_emal_add,
				@message_refresh_time,
				@region_id,
				@user_active,
				@temp_pwd,
				DATEADD(dd, -1, @expire_date), -- since the creation day also should be counted
				@lock_account,
				@reports_to,
				@timezone_id,
				@menu_type_role_id,
				NULLIF(@theme_value_id,''),
				@language,
				IIF(@decimal_separator = '1', ',', @decimal_separator),
				IIF(@group_separator = '1', ',', @group_separator)
			)

			EXEC('spa_application_password_log ''i'', ''' + @user_login_id + ''', NULL, ''' + @user_pwd + '''')

			/* add logic to send mail via template start */
			DECLARE @template_params VARCHAR(5000)
			DECLARE @users_email VARCHAR(1000)

			SET @template_params = ''
			SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<TRM_USER_NAME>', IIF(@cloud_mode = 0, @user_login_id, @user_emal_add))
			SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<TRM_PASSWORD>', @pwd_raw)

			EXEC spa_email_notes
				@flag = 'i',
				@send_to = @user_emal_add,
				@send_status = 'n',
				@active_flag = 'y',
				@email_module_type_value_id = 17808,
				@template_params = @template_params
			/* add logic to send mail via template end */

			COMMIT TRAN

			EXEC spa_ErrorHandler 0, 'Application User',
					'spa_application_User', 'Success',
					'Changes have been saved successfully.', @user_login_id

		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK

			SET @error_no = ERROR_NUMBER()
			SET @error_msg = 'Insert of application users failed.'

			IF (ERROR_SEVERITY() = 16) AND (ERROR_STATE() = 1)
			BEGIN
				SET @error_msg = ERROR_MESSAGE()
			END

			EXEC spa_ErrorHandler @error_no
				, 'Appliction User'
				, 'spa_application_user'
				, 'DB Error'
				, @error_msg
				, ''
		END CATCH
	END
END

ELSE IF @flag = 'u'
BEGIN
	IF EXISTS (SELECT 1 FROM application_users WHERE user_emal_add = @user_emal_add AND user_login_id <> @user_login_id)
	BEGIN
		EXEC spa_ErrorHandler -1, 'Application User',
				'spa_application_User', 'Error',
				'This email ID is already in use. Please enter a different ID.', ''
		RETURN
	END

	BEGIN TRY
		/* Update user data in adiha_cloud first then only update application_users table to make sure email address remains consistent. */
		-- User update at adiha_cloud START
		IF (@cloud_mode = 1)
			BEGIN
			SELECT @api_url = SUBSTRING(file_attachment_path, 0, CHARINDEX('/trm/', file_attachment_path)) + '/api/index.php?route=resolve-path/create-user'
			FROM connection_string

			SET @post_data = '{"user_login_id": "' + @user_login_id + '", "user_f_name": "' + @user_f_name + '", "user_l_name": "' + @user_l_name + '", "user_email_address": "' + @user_emal_add + '", "database_name": "' + @database_name1 + '", "db_server_name": "' + ISNULL(REPLACE(@db_server_name, '\', '\\'), 'NULL') + '"}'

			EXEC spa_push_notification @push_php_url = @api_url, @push_xml = @post_data, @debug_mode = 'y', @output_result = @output_result OUTPUT, @http_web_response = @http_web_response OUTPUT, @authorization_type = 'bearertoken', @access_token = @auth_token

			IF (@output_result = 'success')
			BEGIN
				IF EXISTS (
					SELECT 1
					FROM OPENJSON(@http_web_response)
						WITH (
							[message] VARCHAR(500)
						)
					WHERE [message] = 'not available'
				)
				BEGIN
					RAISERROR ('This email ID is already in use. Please enter a different ID.', 16, 1)
				END
			END
			ELSE
			BEGIN
				RAISERROR ('Please check API configuration. Could not create/update user in cloud database.', 16, 1)
			END
		END
		-- User update at adiha_cloud END

		BEGIN TRAN
		DECLARE @lock_account_status CHAR(1)

		SELECT @lock_account_status = lock_account
		FROM application_users
		WHERE user_login_id = @user_login_id

	UPDATE application_users
	SET	user_f_name = @user_f_name,
		user_m_name = @user_m_name,
		user_l_name = @user_l_name,
		user_title = @user_title,
		entity_id = NULLIF(@entity_id, ''),
		user_address1 = @user_address1,
		user_address2 = @user_address2,
		user_address3 = @user_address3,
		city_value_id = @city_value_id,
		state_value_id = NULLIF(@state_value_id, ''),
		user_zipcode = @user_zipcode,
		user_off_tel = @user_off_tel,
		user_main_tel = @user_main_tel,
		user_pager_tel = @user_pager_tel,
		user_mobile_tel = @user_mobile_tel,
		user_fax_tel = @user_fax_tel,
		user_emal_add = @user_emal_add,
		message_refresh_time = @message_refresh_time,
		region_id = @region_id,
		user_active = @user_active,
		lock_account = @lock_account,
		reports_to_user_login_id = @reports_to,
		timezone_id = @timezone_id,
		menu_type_role_id = @menu_type_role_id,
		theme_value_id = NULLIF(@theme_value_id,''),
		[language] = @language,
		decimal_separator = IIF(@decimal_separator = '1', ',', @decimal_separator),
		group_separator = IIF(@group_separator = '1', ',', @group_separator)
		WHERE user_login_id = @user_login_id

		DECLARE @format VARCHAR(100)
	
		SELECT @format = date_format 
		FROM region 
		WHERE region_id = @region_id
		/*
		/* add logic to send mail via template start */
		DECLARE @template_params_update VARCHAR(5000)
		DECLARE @users_email_update VARCHAR(1000)
	
		SELECT @user_l_name = user_l_name, @user_login_id = user_login_id, @users_email = user_emal_add
		FROM application_users 
		WHERE user_login_id = @user_login_id

		SET @template_params_update = ''
		SET @template_params_update = dbo.FNABuildNameValueXML(@template_params, '<TRM_USER_NAME>', @user_login_id)
		--SET @@template_params_update = dbo.FNABuildNameValueXML(@template_params, '<TRM_USER_LAST_NAME>', @user_l_name)
		SET @template_params_update = dbo.FNABuildNameValueXML(@template_params, '<TRM_PASSWORD>', @temp_pwd)
	
	
		EXEC spa_email_notes
			@flag = 'i',
			@send_to = @users_email,
			@send_status = 'n',
			@active_flag = 'y',
			@email_module_type_value_id = 17809,
			@template_params = @template_params
		/* add logic to send mail via template end */

		*/
		IF (@lock_account_status = 'y' AND @lock_account = 'n')
		BEGIN
			DECLARE @user_login_id_var VARCHAR(150)

			IF @cloud_mode = 1
			BEGIN
				SET @user_login_id_var = @user_emal_add
			END
			ELSE
			BEGIN
				SET @user_login_id_var = @user_login_id
			END

			EXEC spa_system_access_log @flag = 'i', @user_login_id_var = @user_login_id_var, @status = 'Account unlocked by Administrator'
		END		
		
		COMMIT

		EXEC spa_ErrorHandler 0
		   , 'Application User'
		   , 'spa_application_User'
		   , 'Success'
		   , 'Changes have been saved successfully.'
		   , @format	
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK

		SET @error_no = ERROR_NUMBER()
		SET @error_msg = 'Update of application users failed.'

		IF (ERROR_SEVERITY() = 16) AND (ERROR_STATE() = 1)
		BEGIN
			SET @error_msg = ERROR_MESSAGE()
		END
			
		EXEC spa_ErrorHandler @error_no
			, 'Application User'
			, 'spa_application_user'
			, 'DB Error'
			, @error_msg
			, ''
	END CATCH
END	

ELSE IF @flag = 'd'
BEGIN
	DECLARE @check_admin_char VARCHAR(MAX)

	-- Build '0000100', where 0 means not admin and 1 means admin.
	SELECT @check_admin_char = CONCAT(@check_admin_char, CASE WHEN user_login_id = dbo.FNAAppAdminID() THEN 1 ELSE 0 END)
	FROM application_users au
	INNER JOIN dbo.FNASplit(@del_application_users_id, ',') di ON di.item = au.application_users_id

	-- IF @check_admin_char has '1' then the user is Admin, so cannot be deleted.
	IF CHARINDEX('1', @check_admin_char) > 0
	BEGIN
		EXEC spa_ErrorHandler 1, 'System User', 
			'spa_application_user', 'DB Error', 
			'Application administrator user can not be deleted.', ''
		RETURN
	END
	ELSE IF EXISTS(
		SELECT 1
		FROM msdb.dbo.sysjobs_view mv
		INNER JOIN dbo.FNASplit(@del_application_users_id, ',') di ON SUSER_SID(di.item) = mv.owner_sid
	)
	BEGIN
		EXEC spa_Errorhandler -1,'This user IS the owner of a job. You must delete or reassign the job before the user can be deleted.',
			'spa_application_db_user','DB Error',
			'This user is the owner of a job. You must delete or reassign the job before the user can be deleted.',''
		RETURN
	END
	ELSE
	BEGIN
		BEGIN TRY
			DECLARE @del_user_login_ids VARCHAR(MAX)

			SELECT @del_user_login_ids = STUFF(
				(
					SELECT ',' + user_login_id
					FROM application_users au
					INNER JOIN dbo.FNASplit(@del_application_users_id, ',') di 
						ON di.item = au.application_users_id
					FOR XML PATH ('')
				)
			, 1, 1, '') 
			
			-- Delete user at adiha_cloud START
			IF @cloud_mode = 1
			BEGIN
				DECLARE @del_user_email_ids VARCHAR(MAX)

				SELECT @del_user_email_ids = STUFF(
					(
						SELECT ',' + user_emal_add
						FROM application_users au
						INNER JOIN dbo.FNASplit(@del_application_users_id, ',') di 
							ON di.item = au.application_users_id
						FOR XML PATH ('')
					)
				, 1, 1, '')	

				IF @del_user_email_ids <> ''
				BEGIN
					SELECT @api_url = SUBSTRING(file_attachment_path, 0, CHARINDEX('/trm/', file_attachment_path)) + '/api/index.php?route=resolve-path/delete-user'
					FROM connection_string

					SELECT @post_data = '{"user_data": "[' + ( STUFF(
						( SELECT ',' + '{\"user_email_add\": \"' + e.item + '\"}'
						  FROM dbo.FNASplit(@del_user_email_ids, ',') e
						  FOR XML PATH ('')
						), 1, 1, '')
					) + ']"}'

					EXEC spa_push_notification @push_php_url = @api_url, @push_xml = @post_data, @debug_mode = 'y', @output_result = @output_result OUTPUT, @http_web_response = @http_web_response OUTPUT, @authorization_type = 'bearertoken', @access_token = @auth_token

					IF (@output_result <> 'success')
					BEGIN
						EXEC spa_ErrorHandler @error_no
							, 'Application User'
							, 'spa_application_user'
							, 'API Error'
							, 'Please check API configuration. Could not delete user in cloud database.'
							, ''
					END
				END
			END
			-- Delete user at adiha_cloud END

			BEGIN TRAN

			UPDATE fs
			SET contact_user_id = NULL
			FROM fas_subsidiaries fs
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = fs.contact_user_id

			UPDATE rl
			SET report_owner_login_id = NULL
			FROM report_layout rl
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = rl.report_owner_login_id

			UPDATE st
			SET user_login_id = NULL
			FROM source_traders st
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = st.user_login_id

			UPDATE cce
			SET approved_by = NULL
			FROM counterparty_credit_enhancements cce
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = cce.approved_by

			UPDATE cci
			SET approved_by = NULL
			FROM counterparty_credit_info cci
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = cci.approved_by

			DELETE aufd
			FROM application_ui_filter_details aufd
			INNER JOIN application_ui_filter auf ON auf.application_ui_filter_id = aufd.application_ui_filter_id
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = auf.user_login_id

			DELETE prd
			FROM process_risk_description prd
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = prd.risk_owner

			DELETE pch
			FROM process_control_header pch
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = pch.process_owner

			DELETE prc
			FROM process_risk_controls prc
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = prc.perform_user
				OR prc.approve_user = di.item

			DELETE auf
			FROM application_ui_filter auf
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = auf.user_login_id

			DELETE afu
			FROM application_functional_users afu
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = afu.login_id

			DELETE aru
			FROM application_role_user aru
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = aru.user_login_id

			DELETE aupl
			FROM application_users_password_log aupl
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = aupl.user_login_id

			DELETE draa
			FROM deal_rec_assignment_audit draa
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = draa.assigned_by

			DELETE mg
			FROM menu_group mg
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = mg.[user_id]

			DELETE mb
			FROM message_board mb
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = mb.user_login_id

			DELETE rmvu
			FROM report_manager_view_users rmvu
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = rmvu.login_id

			DELETE rwvu
			FROM report_writer_view_users rwvu
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = rwvu.login_id

			DELETE prce
			FROM process_risk_controls_email prce
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = prce.inform_user

			DELETE au
			FROM alert_users au
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = au.user_login_id

			DELETE ipp
			FROM ipx_privileges ipp
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = ipp.[user_id]

			DELETE tmp
			FROM template_mapping_privilege tmp
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = tmp.[user_id]

			DELETE sw
			FROM setup_workflow sw
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = sw.[user_id]

			DELETE dl
			FROM device_logins dl
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = dl.user_login_id

			DELETE pdp
			FROM pivot_dashboard_privilege pdp
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = pdp.user_login_id

			DELETE prcau
			FROM process_risk_controls_activities_audit prcau
			INNER JOIN process_risk_controls_activities prca ON prca.risk_control_activity_id = prcau.risk_control_activity_id
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = prca.approved_by

			DELETE prca
			FROM process_risk_controls_activities prca
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = prca.approved_by

			DELETE bpn
			FROM batch_process_notifications bpn
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = bpn.user_login_id

			DELETE wa
			FROM workflow_activities wa
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = wa.approved_by

			DELETE dpf
			FROM deal_pricing_filter dpf
			INNER JOIN dbo.FNASplit(@del_user_login_ids, ',') di ON di.item = dpf.[user_name]

			DELETE au
			FROM application_users au
			INNER JOIN dbo.FNASplit(@del_application_users_id, ',') di ON di.item = au.application_users_id

			COMMIT
				
			EXEC spa_ErrorHandler 0, 'Database User', 
				'spa_application_db_User', 'Success', 
				'Changes have been saved successfully.', ''
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRAN
			
			DECLARE @error_num INT
			SET @error_num = ERROR_NUMBER()

			IF ERROR_NUMBER() = 15434
			BEGIN
				EXEC spa_ErrorHandler -1, 'Application User', 
					'spa_application_user', 'DB Error', 
					'Deletion of application user failed. The selected user is currently logged in.', ''	
			END
			ELSE IF (ERROR_SEVERITY() = 16) AND (ERROR_STATE() = 1)
			BEGIN
				SET @error_msg = ERROR_MESSAGE()

				EXEC spa_ErrorHandler @error_no
					, 'Application User'
					, 'spa_application_user'
					, 'DB Error'
					, @error_msg
					, ''
			END
			ELSE
			BEGIN					
				SELECT 'Error' ErrorCode
					 , 'Application User' Module
					 , 'spa_application_user' Area
					 , 'DB Error' [Status]
					 , 'Deletion of application user failed. ' + dbo.FNAHandleDBError(10111000) [Message] -- 10111000 function_id for Setup User
					 , '' Recommendation			
			END
		END CATCH
	END
END

ELSE IF @flag = 'l'
BEGIN
		

	IF dbo. FNASecurityAdminRoleCheck(@user_login_id) = 0
	AND dbo. FNAAppAdminRoleCheck(@user_login_id) = 0	
	BEGIN	
		UPDATE application_users
		SET lock_account=@lock_account
		WHERE 	user_login_id=@user_login_id AND user_login_id<>dbo.FNAAppAdminID()
		
		IF @@ERROR<>0
			EXEC spa_Errorhandler @@ERROR,"Database User",
					"spa_application_db_user","DB Error",
					"Failed to update lock user."
		ELSE
		BEGIN			
			EXEC spa_ErrorHandler 0, 'Database User', 
					'spa_application_db_User', 'Success', 
					' Account User Successfully locked', ''
		END
	END
	ELSE 
	BEGIN
					EXEC spa_ErrorHandler 0, 'Database User', 
				'spa_application_db_User', 'super_users', 
				' Account cannot be lock to this users.', ''
	END
END

ELSE IF @flag = 'j'
BEGIN
	SELECT 'All' AS [Parent],
			user_login_id AS [user_login_id], 
			user_f_name AS [First Name], 
			user_m_name AS [Middle Name], 
			user_l_name AS [Last Name]
	FROM application_users 
	ORDER BY user_f_name
END

ELSE IF @flag = 'v'
BEGIN
	SELECT 
		user_login_id,
		user_f_name + ' ' + ISNULL(user_m_name + ' ', '') + user_l_name 
	FROM 
		application_users 
	WHERE user_login_id <> dbo.FNADBUser()
		AND user_login_id NOT IN (SELECT 
										user_login_id
								   FROM  batch_process_notifications
								   WHERE process_id = @process_id
										AND user_login_id IS NOT NULL) 
	ORDER BY user_f_name

	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, 'Appliction User', 
				'spa_application_user', 'DB Error', 
				'Selection of all application users failed.', ''
END

ELSE IF @flag = 'p'
BEGIN
	IF 1 <> Has_perms_by_name(NULL, NULL, 'ALTER ANY LOGIN')
	BEGIN
		EXEC spa_ErrorHandler -1, 'Application User', 
				'spa_application_User', 'Error', 
				'This user is not authorized to perform this action.', ''
		RETURN
	END
	ELSE
	BEGIN
		EXEC spa_ErrorHandler 0, 'Application User', 
				'spa_application_User', 'Success', 
				'Success', ''
	END
END
--SELECT all users for dhtmlx grid maintain users
ELSE IF @flag = 'a' AND @user_login_id IS NOT NULL
BEGIN
	SELECT user_login_id, user_f_name + ' ' + ISNULL(user_m_name, '') + ' ' + user_l_name AS name
	FROM application_users 
	WHERE user_login_id = @user_login_id 
	ORDER BY user_f_name
END

ELSE IF @flag = 'a' AND @user_login_id IS NULL
BEGIN
	SELECT user_login_id, 
			user_f_name + ' ' + ISNULL(user_m_name, '') + ' ' + user_l_name AS name
	FROM application_users 
	ORDER BY user_f_name
END

ELSE IF @flag = 'f'
BEGIN
	SELECT au.user_login_id , 
		au.user_f_name + ' ' + ISNULL(au.user_m_name, '') + ' ' + au.user_l_name AS name
	FROM application_users au 
		LEFT JOIN application_role_user aru 
			ON aru.user_login_id = au.user_login_id 
			AND aru.role_id = @user_role
	WHERE aru.user_login_id IS NULL
	ORDER BY user_f_name
END

ELSE IF @flag = 'w' AND @user_login_id IS NOT NULL
BEGIN
	SELECT au.user_pwd 
		   ,au.user_pwd AS [User Password]
		   ,au.user_f_name
		   ,au.user_l_name
		   ,au.user_emal_add
	FROM application_users au
	WHERE user_login_id = @user_login_id
END

ELSE IF @flag = 'x'
BEGIN
	SET @user_login_id = dbo.FNADBUser()

	DECLARE @show_all_user_for_func_id VARCHAR(500) 
	DECLARE @show_all_user AS BIT = 0

	IF EXISTS  (
		SELECT 1 
		FROM (
			SELECT function_id 
			FROM application_functional_users 
			WHERE login_id = @user_login_id 
			UNION
			SELECT function_id 
			FROM application_role_user aru
				INNER JOIN application_functional_users afu
					ON aru.role_id = afu.role_id
					WHERE user_login_id = @user_login_id) sub
			WHERE sub.function_id = 10111000 --(Setup User View Privilege)
	) 
	BEGIN
		SET @show_all_user = 1
	END

	IF dbo.FNAAppAdminRoleCheck(@user_login_id) = 1 
		OR dbo.FNAIsUserOnAdminGroup(@user_login_id, 0) = 1 
		OR @show_all_user = 1			
		OR dbo.FNASecurityAdminRoleCheck(@user_login_id) = 1
	BEGIN
		SELECT  user_login_id, 
				user_f_name + ISNULL(' ' + NULLIF(user_m_name, ''), '') + ' ' + user_l_name AS name,
				application_users_id
		FROM application_users 
		ORDER BY name
	END
	ELSE 
	BEGIN
		SELECT user_login_id, 
				user_f_name + ISNULL(' ' + NULLIF(user_m_name, ''), '') + ' ' + user_l_name AS name,
				application_users_id
		FROM application_users 
		WHERE user_login_id = @user_login_id
		ORDER BY name
	END
END

ELSE IF @flag = 'z'
BEGIN 
	IF @user = 'All' OR @role = 'All'
	BEGIN 
		SET @sql_stmt = 'SELECT DISTINCT ' + CASE WHEN @user_role = 1 
										THEN 'RTRIM(user_login_id) user_login_id, RTRIM(user_login_id) [name]' 
										ELSE 'role_name, role_name' 
									END 
						+ ' FROM ' + CASE WHEN @user_role = 1 THEN 'application_users' ELSE 'application_security_role' END  + ' au '
						+ CASE WHEN @include_exclude = 'i' THEN ' WHERE 1=1' ELSE '  WHERE 1=2 ' END 						
	END 
	ELSE 
	BEGIN 
		CREATE TABLE #user_role(name VARCHAR(1000) COLLATE DATABASE_DEFAULT )
		SET @sql_stmt = 'INSERT INTO #user_role
						SELECT * FROM dbo.FNASplit(''' + CASE WHEN @user_role = 1 THEN @user ELSE @role END + ''', '','') '
	
		
		EXEC(@sql_stmt)
	
		SET @sql_stmt = 'SELECT DISTINCT ' + CASE WHEN @user_role = 1 
										THEN 'RTRIM(user_login_id) user_login_id, dbo.FNAGetUserName(user_login_id) [name]' 
										ELSE 'role_name, role_name' 
									END 
						+ ' FROM ' + CASE WHEN @user_role = 1 THEN 'application_users' ELSE 'application_security_role' END  + ' au '
						+ ' WHERE ' + CASE WHEN @user_role = 1 THEN 'au.user_login_id' ELSE 'RTRIM(LTRIM(au.role_name))' END  + 
						+ CASE WHEN @include_exclude = 'i' THEN ' IN ' ELSE ' NOT IN  ' END 
						+ '(SELECT name FROM #user_role)'		
	END
	
	EXEC(@sql_stmt)
END
 
-- Identify user_login_id using user email address. Used in reset password logic from website.
ELSE IF @flag = 'n'
BEGIN
	SELECT user_login_id
		 , user_f_name
		 , user_l_name
	FROM application_users
	WHERE user_emal_add = @user_emal_add
END

-- Change password from website
ELSE IF @flag = 'r'
BEGIN
	IF EXISTS (SELECT 1 FROM application_users WHERE user_emal_add = @user_emal_add)
	BEGIN
		DECLARE @current_pwd VARCHAR(50)

		SELECT @current_pwd = user_pwd FROM application_users WHERE user_emal_add = @user_emal_add
		
		IF (@current_pwd <> @user_pwd)
		BEGIN
			SELECT 'Error' AS ErrorMessage
				 , 'Current Password is incorrect.' AS [Message]
			RETURN
		END

		IF (@user_pwd <> @new_pwd) --check if new pwd is same as old one
		AND NOT EXISTS ( SELECT 1 FROM (
							SELECT TOP(4) [log].user_pwd
							FROM application_users_password_log [log]
							INNER JOIN application_users au
								ON au.user_login_id = [log].user_login_id
							WHERE au.user_emal_add = @user_emal_add
							ORDER BY [log].as_of_date DESC
					    ) historical_pwd
					    WHERE historical_pwd.user_pwd = @new_pwd --check if new pwd has been used previously
		)
		BEGIN
			UPDATE application_users
			SET user_pwd = @new_pwd
			  , temp_pwd = 'n'
			  , expire_date = DATEADD(DD, @pwd_expiry_days, GETDATE())
			WHERE user_emal_add = @user_emal_add

			INSERT INTO application_users_password_log (
				user_login_id
			  , as_of_date
			  , user_pwd
			)
			SELECT user_login_id
				 , GETDATE()
				 , @new_pwd
			FROM application_users
			WHERE user_emal_add = @user_emal_add

			SELECT 'Success' AS ErrorMessage
				 , 'Your password has been reset successfully.' AS [Message]
		END
		ELSE
		BEGIN
			SELECT 'Error' AS ErrorMessage
				 , 'You are not allowed to reuse your previous four password.' AS [Message]
		END
	END
	ELSE
	BEGIN
		SELECT 'Error' AS ErrorMessage
			 , 'Password change failed.' AS [Message]
	END
END

-- Set/unset user as read-only
ELSE IF @flag = 'e'
BEGIN
	BEGIN TRY
		BEGIN TRAN

		UPDATE au 
		SET read_only_user = @read_only_user
		FROM application_users au
		INNER JOIN dbo.FNASplit(@user_login_id, ',') i
			ON i.item = au.user_login_id

		COMMIT

		EXEC spa_ErrorHandler 0
			, 'Application User'
			, 'spa_application_User'
			, 'Success'
			, 'Changes has been successfully saved.'
			, ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK

		SET @error_msg = 'Could not set user(s) as read-only.'

		EXEC spa_ErrorHandler @error_no
			, 'Application User'
			, 'spa_application_user'
			, 'DB Error'
			, @error_msg
			, ''
	END CATCH
END
ELSE IF @flag = 'o'
BEGIN
	IF (@ixp_rules_id is NOT NULL)
	BEGIN
		SELECT au.user_login_id, user_f_name + ' ' + ISNULL(user_m_name, '') + ' ' + user_l_name AS name
		FROM application_users au
		INNER JOIN  workflow_event_user_role inn ON inn.user_login_id =au.user_login_id 
			INNER JOIN ixp_import_data_source imds ON imds.message_id = inn.event_message_id
		where imds.rules_id= @ixp_rules_id
	END
END

ELSE IF @flag = 'b'
BEGIN
	IF (@ixp_rules_id is NOT NULL)
	BEGIN
		SELECT au.user_login_id, user_f_name + ' ' + ISNULL(user_m_name, '') + ' ' + user_l_name AS name
		FROM application_users au
		LEFT JOIN workflow_event_user_role ixn ON au.user_login_id = ixn.user_login_id
		LEFT JOIN ixp_import_data_source imds ON imds.message_id = ixn.event_message_id and rules_id = @ixp_rules_id
		where ixn.user_login_id is null
	END
END

ELSE IF (@flag = 'q' AND @user is not null)
BEGIN
	select Distinct item into #temp_users FROM  dbo.SplitCommaSeperatedValues(@user) 
	
 SELECT
   distinct  
    stuff((
        select ',' + u.user_login_id
        from application_users u
       	INNER JOIN #temp_users tn ON tn.item = dbo.FNAGetUserName(u.user_login_id)
        order by u.user_login_id
        for xml path('')
    ),1,1,'') as userlist
from application_users
END

ELSE IF @flag = 'h'
BEGIN
	SELECT 
		user_login_id,
		user_f_name + ' ' + ISNULL(user_m_name + ' ', '') + user_l_name 
	FROM 
		application_users 
	WHERE 
		 user_login_id NOT IN (SELECT 
										user_login_id
								   FROM  batch_process_notifications
								   WHERE process_id = @process_id
										AND user_login_id IS NOT NULL) 
	ORDER BY user_f_name
END
ELSE IF @flag = 'y'
BEGIN
	SELECT decimal_separator [default_decimal_separator], group_separator [default_group_separator]
	FROM company_info
END