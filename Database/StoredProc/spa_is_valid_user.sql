IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_is_valid_user]') AND type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_is_valid_user]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Stored Procedure to check if user is a valid application user.

	Parameters 
	@user_login_id : User Login ID of application user
	@user_pwd : Encrypted user password
	@ip_address : IP address of the user
	@system_name : Host name of the user
	@ldap_valid : '1' if authentication is done by validating username and password combination with a directory server such as MS Active Directory, OpenLDAP or OpenDJ etc else '0'
	@windows_auth : '1' if windows authentication is used for login '0' for SQL authentication
	@login_attempts : Number of login attempts made by the user trying to login
	@access_log_time_range : Time range in hours where the user has tried logging into application. This is used to lock user account if user has made multiple incorrect attempts within certain time range as configured in application
	@cloud_mode : '1' if SaaS mode is turned on else '0'
	@client_dir : Client configuration directory. Example: 'trmclient', 'trmcloud', 'setclient' etc.
	@cookie_hash : Unique hash key used to identify user machine which has completed two factor authentication
*/

CREATE PROC [dbo].[spa_is_valid_user]
	@user_login_id VARCHAR(50),
	@user_pwd VARCHAR(50),
	@ip_address VARCHAR(100),
	@system_name VARCHAR(100),
	@ldap_valid INT = 0,
	@windows_auth INT = 0,
	@login_attempts INT = 3,
	@access_log_time_range INT = 24,
	@cloud_mode INT = 0,
	@client_dir VARCHAR(50) = NULL,
	@cookie_hash VARCHAR(100) = NULL
AS 

SET NOCOUNT ON

/*
DECLARE @user_login_id VARCHAR(50),
		@user_pwd VARCHAR(50),
		@ip_address VARCHAR(100),
		@system_name VARCHAR(100),
		@ldap_valid INT = 0,
		@windows_auth INT = 0,
		@login_attempts INT = 3,
		@access_log_time_range INT = 24,
		@cloud_mode INT = 0,
		@client_dir VARCHAR(50) = NULL,
		@cookie_hash VARCHAR(100) = NULL

SELECT @user_login_id='release_4230', @user_pwd='nkdt03sgoJpQsGo', @ip_address='20.2.200.12', @system_name='20.2.200.12', @ldap_valid=1, @windows_auth=0, @login_attempts=3, @access_log_time_range=24, @cloud_mode=1, @client_dir='trmcloud', @cookie_hash=''
--*/

DECLARE @user VARCHAR(50) = NULL
DECLARE @pwd VARCHAR(50) = NULL
DECLARE @user_active CHAR(1)
DECLARE @lock_account CHAR(1)
DECLARE @user_full_name VARCHAR(128)
DECLARE @message VARCHAR(1000) = 'Database rights for ' +  dbo.FNADBUser() + ' login id have not been set up correctly. Please contact your Database Administrator.'
DECLARE @user_email VARCHAR(150)
DECLARE @temp_pwd CHAR(1),
		@expire_date DATETIME,
		@user_time_zone VARCHAR(50),
		@user_date_format VARCHAR(100)

SELECT	@user = au.user_login_id,
		@pwd = au.user_pwd,
		@user_active = au.user_active,
		@lock_account = au.lock_account,
		@user_full_name = au.user_f_name + ISNULL(' ' + NULLIF(au.user_m_name, ''), '') + ' ' + au.user_l_name,
		@user_email = au.user_emal_add,
		@temp_pwd = CASE WHEN au.temp_pwd = 'y' THEN 'y'
						 WHEN CAST(GETDATE() AS DATE) > CAST(au.expire_date AS DATE) THEN 'y'
						 ELSE 'n' END,
		@expire_date = au.expire_date,
		@user_time_zone = tz.TIMEZONE_NAME_FOR_PHP,
		@user_date_format = r.[date_format]
FROM application_users au
LEFT JOIN time_zones tz ON au.timezone_id = tz.timezone_id
LEFT JOIN region r ON r.region_id = au.region_id
WHERE user_login_id = @user_login_id 

SELECT @pwd = LTRIM(RTRIM(@pwd)), @user_pwd = LTRIM(RTRIM(@user_pwd))

/* Logic to prevent login upon exceeding defined no. of concurrent users depending upon the application. 
   Added new logic to allow application login if user is internal pioneer user.
*/
DECLARE @timeout INT
	  , @current_date_time DATETIME = GETDATE()
	  , @concurrent_users INT
	  , @exceeded_logins CHAR(1)
	  , @priority_user BIT
	  , @logout_user VARCHAR(100)

IF NOT EXISTS( SELECT 1
			   FROM application_users
			   WHERE user_login_id = @user_login_id
					AND ISNULL([entity_id], 0) = -10076 )
BEGIN
	IF OBJECT_ID('tempdb..#priority_users') IS NOT NULL
		DROP TABLE #priority_users

	-- Get session timeout duration to calculate user having max inactivity
	SELECT @timeout = var_value 
	FROM adiha_default_codes adc
	INNER JOIN adiha_default_codes_values adcv
		ON adcv.default_code_id = adc.default_code_id
	WHERE default_code = 'session_timeout'

	SELECT aru.user_login_id
	INTO #priority_users
	FROM application_security_role asr
	LEFT JOIN application_role_user aru
		ON aru.role_id = asr.role_id
	WHERE asr.role_type_value_id = 23

	SELECT @priority_user = CASE WHEN user_login_id IS NOT NULL THEN 1 ELSE 0 END
	FROM #priority_users
	WHERE user_login_id = @user_login_id

	IF OBJECT_ID('tempdb..#active_users') IS NOT NULL
		DROP TABLE #active_users

	CREATE TABLE #active_users (
		user_login_id NVARCHAR(100)
	  , time_diff DATETIME
	  , actual_active_session BIT
	)

	-- Get number of concurrent users allowed for given application
	IF EXISTS( SELECT 1
				FROM application_users
				WHERE user_login_id = @user_login_id
				AND read_only_user = 'y' )
	BEGIN
		SELECT @concurrent_users = ISNULL(concurrent_read_only_users, total_read_only_users)
		FROM application_license

		INSERT INTO #active_users (
			user_login_id
		  , time_diff
		  , actual_active_session
		)
		SELECT ts.create_user
				, DATEDIFF(s, ts.last_request_ts, @current_date_time)
				, CASE WHEN DATEDIFF(s, ts.last_request_ts, @current_date_time) < @timeout THEN 1 ELSE 0 END
		FROM trm_session ts
		INNER JOIN application_users au
			ON ts.create_user = au.user_login_id
		WHERE ts.is_active = 1
			AND DATEDIFF(s, ts.last_request_ts, @current_date_time) < @timeout
			AND ts.create_user <> @user_login_id
			AND ISNULL([entity_id], 0) <> -10076 -- Do not count internal pioneer users
			AND au.read_only_user = 'y' -- Count read only users only
	END
	ELSE
	BEGIN
		SELECT @concurrent_users = ISNULL(concurrent_users, total_users)
		FROM application_license

		INSERT INTO #active_users (
			user_login_id
		  , time_diff
		  , actual_active_session
		)
		SELECT ts.create_user
				, DATEDIFF(s, ts.last_request_ts, @current_date_time)
				, CASE WHEN DATEDIFF(s, ts.last_request_ts, @current_date_time) < @timeout THEN 1 ELSE 0 END
		FROM trm_session ts
		INNER JOIN application_users au
			ON ts.create_user = au.user_login_id
		WHERE ts.is_active = 1
			AND DATEDIFF(s, ts.last_request_ts, @current_date_time) < @timeout
			AND ts.create_user <> @user_login_id
			AND ISNULL([entity_id], 0) <> -10076 -- Do not count internal pioneer users
			AND ISNULL(au.read_only_user, 'n') <> 'y' -- Do not count read only user for active users
	END

	SELECT @exceeded_logins = CASE WHEN @priority_user = 1 AND COUNT(user_login_id) >= @concurrent_users THEN 's'  -- Priority user
								   WHEN COUNT(user_login_id) >= @concurrent_users THEN 'y' -- 'y' - Concurrent users have exceeded
								   ELSE 'n' -- 'n' - Concurrent users have not exceeded
							  END
	FROM #active_users

	-- Now logout a user from application by expiring another user's session if current user if priority user
	IF @exceeded_logins = 's'
	BEGIN
		SELECT TOP 1 @logout_user = au.user_login_id
		FROM #active_users au
		LEFT JOIN #priority_users pu
			ON pu.user_login_id = au.user_login_id
		WHERE pu.user_login_id IS NULL
		ORDER BY time_diff DESC

		-- Remove a priority user if necessary in case where all active users are priority users
		IF @logout_user IS NULL
		BEGIN
			SELECT TOP 1 @logout_user = au.user_login_id
			FROM #active_users au
			LEFT JOIN #priority_users pu
				ON pu.user_login_id = au.user_login_id
			ORDER BY time_diff DESC
		END

		-- IF @logout_user is still null means there is no active session to logout hence even this user cannot login
		IF @logout_user IS NULL
		BEGIN
			SELECT @exceeded_logins = 'y'
		END
		ELSE
		BEGIN
			UPDATE trm_session
			SET is_active = 0
			WHERE create_user = @logout_user
				AND is_active = 1
		END
	END
END
/* End of Logic to prevent login */

/* Update the status from Outstanding to 'Pending Mitigation' for all the activities whose Mitigation Plan Required is 'y' AND
the current date has already exceeded the exception date AND to whom no action has been performed yet
*/
IF EXISTS(SELECT 'X' FROM process_risk_controls_activities prca 
				JOIN dbo.process_risk_controls prc 
					ON prca.risk_control_id = prc.risk_control_id
				WHERE dbo.FNAGetSQLStandardDate(getdate()) > prca.exception_date
					AND prca.control_status = 725
					AND prc.mitigation_plan_required = 'y'
					AND NOT EXISTS (SELECT risk_control_id FROM process_risk_controls_activities_audit a WHERE a.risk_control_id = prca.risk_control_id))
BEGIN
	EXEC dbo.spa_update_process @user_login_id ,NULL,2
END	

-- No user found
IF @user IS NULL
BEGIN
	IF @cloud_mode = 0
	BEGIN
		EXEC spa_system_access_log 'i', @user_login_id, @ip_address, @system_name, 'User not found'
	END
	ELSE
	BEGIN
		EXEC spa_system_access_log 'i', @user_email, @ip_address, @system_name, 'User not found'
	END
	
	SELECT 'Error' [ErrorCode], 
			'Appliction User' [Module], 
			'spa_is_valid_user' Area,
			'Security Error' [Status] , 
			 CASE WHEN @cloud_mode = 0 THEN @user_login_id + ' is not valid login id.'
								       ELSE 'User does not exist in application. Please try again.' END [Message],
			'Please try again.' [Recommendation],
			@exceeded_logins [ExceededLogins],
			@temp_pwd [TemporaryPassword]			
END
ELSE
BEGIN
	-- If user is found
	-- Chek user acccount activation status
	IF @user_active = 'n' 
	BEGIN
		IF @cloud_mode = 0
		BEGIN
			EXEC spa_system_access_log 'i',@user_login_id, @ip_address, @system_name, 'User Not Activated'
		END
		ELSE
		BEGIN
			EXEC spa_system_access_log 'i',@user_email, @ip_address, @system_name, 'User Not Activated'
		END
				
		SELECT 'Error' [ErrorCode], 'Appliction User' [Module], 
				'spa_is_valid_user' [Area], 'Security Error' [Status], 
				( IIF(@cloud_mode = 0, @user_login_id, @user_email) + ' login id is inactive. Please contact your system administrator to activate.' ) [Message],
				'inactive' [Recommendation],
				@exceeded_logins [ExceededLogins],
				@temp_pwd [TemporaryPassword]
		
		RETURN
	END
	-- Chek user acccount lock status
	ELSE IF @lock_account = 'y' 
	BEGIN
		IF @cloud_mode = 0
		BEGIN
			SET @message = 'Your account has been locked. Please contact the administrator to unlock your account.'
			EXEC spa_system_access_log 'i',@user_login_id, @ip_address, @system_name, 'User Account is locked'
		END
		ELSE
		BEGIN
			SET @message = 'Your account has been locked due to maximum number of unsuccessful login attempts. To restore your access, please reset your password by clicking on ''Forgot Password'' below.'
			EXEC spa_system_access_log 'i',@user_email, @ip_address, @system_name, 'User Account is locked'
		END
		
		SELECT 'Error' [ErrorCode], 'Appliction User' [Module], 
				'spa_is_valid_user' [Area], 'Security Error' [Status], 
				@message [Message], 
				@lock_account [Recommendation],
				@exceeded_logins [ExceededLogins],
				@temp_pwd [TemporaryPassword]
		
		RETURN
	END
     -- Check if user has permission on adiha_process database
	ELSE IF (has_perms_by_name('adiha_process', 'Database', 'Create Table'))<>1
    BEGIN
        SELECT	'Error' [ErrorCode], 'Appliction User' [Module], 
                'spa_is_valid_user' [Area], 'InValid User' [Status], 
                @message [Message] , '' [Recommendation],
				@exceeded_logins [ExceededLogins],
				@temp_pwd [TemporaryPassword]
		RETURN
    END
	-- Check if user has bulkadmin role
	ELSE IF (SELECT IS_SRVROLEMEMBER('bulkadmin'))<>1
    BEGIN
        SELECT	'Error' [ErrorCode],
				'Appliction User' [Module], 
                'spa_is_valid_user' [Area],
				'InValid User' [Status],
                @message [Message],
				'' [Recommendation],
				@exceeded_logins [ExceededLogins],
				@temp_pwd [TemporaryPassword]

		RETURN
	END
	ELSE
	BEGIN
		-- Check if user has database role 'SQLAgentUserRole'
		-- IF user is 'sysadmin' no need to depend on 'SQLAgentUserRole'
		DECLARE @hasUserRole INT
		DECLARE @sysadmin INT
		
		SELECT @sysadmin = IS_SRVROLEMEMBER('sysadmin');

		IF OBJECT_ID('tempdb..#role') IS NOT NULL
			DROP TABLE #role

		CREATE TABLE #role (hasUserRole INT)

		INSERT INTO #role
		EXEC ('
			USE msdb;
			SELECT IS_MEMBER(''SQLAgentUserRole'')'
		);

		SELECT @hasUserRole = hasUserRole FROM #role

		IF NOT (@sysadmin = 1 OR @hasUserRole = 1)
		BEGIN
			SELECT	'Error' [ErrorCode], 'Application User' [Module],
					'spa_is_valid_user' [Area], 'InValid User' [Status],
					@message [Message] , '' [Recommendation],
					@exceeded_logins [ExceededLogins],
					@temp_pwd [TemporaryPassword]
			RETURN
		END
		-- Check if db password and user entered password match/ If win auth/ If LDAP valid
		ELSE IF @pwd = @user_pwd OR @ldap_valid = 0 OR @windows_auth = 1
		BEGIN
			DECLARE @enable_otp INT
				  , @otp_expiry_days INT
				  , @cookie_auth VARCHAR(100)
				  
			SELECT @enable_otp = dbo.FNAOTPStatus(@client_dir)
				 , @otp_expiry_days = ISNULL(otp_expiry_days, 5)
			FROM connection_string

			IF @cookie_hash = ''
			BEGIN
				SET @cookie_auth = NULL
			END
			ELSE
			BEGIN
				SET @cookie_auth = @cookie_hash
			END

			-- Enable otp if user login from new device or last login before 4 days
			IF (@enable_otp = 1) AND EXISTS (
						SELECT 1 FROM system_access_log 
						WHERE user_login_id = IIF(@cloud_mode = 0, @user_login_id, @user_email)
							AND DATEDIFF(DAY, access_timestamp , getdate()) < @otp_expiry_days 
							AND [status] = 'Success'
							AND cookie_hash = ISNULL(@cookie_auth, 0)
			)
			BEGIN
				SET @enable_otp = 0;

				IF @cloud_mode = 0
				BEGIN
					EXEC spa_system_access_log @flag='i',@user_login_id_var=@user_login_id, @system_address=@ip_address, @system_name=@system_name, @status='Success', @cookie_hash=@cookie_auth
				END
				ELSE
				BEGIN
					EXEC spa_system_access_log @flag='i',@user_login_id_var=@user_email, @system_address=@ip_address, @system_name=@system_name, @status='Success', @cookie_hash=@cookie_auth
				END
			END
			ELSE IF @enable_otp = 0
			BEGIN
				IF @cloud_mode = 0
				BEGIN
					EXEC spa_system_access_log @flag='i',@user_login_id_var=@user_login_id, @system_address=@ip_address, @system_name=@system_name, @status='Success', @cookie_hash=@cookie_auth
				END
				ELSE
				BEGIN
					EXEC spa_system_access_log @flag='i',@user_login_id_var=@user_email, @system_address=@ip_address, @system_name=@system_name, @status='Success', @cookie_hash=@cookie_auth
				END
			END
			
			DECLARE @error_code VARCHAR(10) = 'Success'
			SET @message = (@user_login_id + ' is a valid login id.|' + CAST(@enable_otp AS VARCHAR(2)))

			IF @exceeded_logins = 'y'
			BEGIN
				SET @error_code = 'Error'
				
				IF EXISTS( SELECT 1
						   FROM application_users
						   WHERE user_login_id = @user_login_id
						   AND read_only_user = 'y' )
				BEGIN
					SET @message = 'You have exceeded the number of allowed active users for read-only license. Please try again later.';
				END
				ELSE
				BEGIN
					SET @message = 'You have exceeded the number of allowed active users. Please try again later.';
				END
				
			END

			SELECT @error_code [ErrorCode]
				 , 'Application User' [Module]
				 , 'spa_is_valid_user' [Area]
				 , 'Valid User' [Status]
				 , @message [Message]
				 , @user_full_name [Recommendation]
				 , @exceeded_logins [ExceededLogins]
				 , @temp_pwd [TemporaryPassword]
				 , @expire_date [expire_date]
				 , @user_time_zone [user_time_zone]
				 , @user_date_format [user_date_format]
		END
		ELSE
		BEGIN
			DECLARE @sql_stmt VARCHAR(MAX)
			
			IF OBJECT_ID('tempdb..#final_status') IS NOT NULL
				DROP TABLE #final_status
			
			CREATE TABLE #final_status (
				[message] VARCHAR(200),
				[recommendation] VARCHAR (200)
			)
			
			IF @cloud_mode = 0
			BEGIN
				EXEC spa_system_access_log 'i',@user_login_id, @ip_address, @system_name, 'Invalid Password'
			END
			ELSE
			BEGIN
				EXEC spa_system_access_log 'i',@user_email, @ip_address, @system_name, 'Invalid Password'
			END

			IF OBJECT_ID('tempdb..#system_access_log') IS NOT NULL
				DROP TABLE #system_access_log
			
			DECLARE @invalid_attempts VARCHAR(200) = ''
				  , @invalid_attempts_count INT

			SELECT * 
			INTO #system_access_log
			FROM system_access_log
			WHERE access_timestamp BETWEEN DATEADD(HH, -1 * @access_log_time_range, GETDATE()) AND GETDATE()
				AND user_login_id = IIF(@cloud_mode = 0, @user_login_id, @user_email)
			ORDER BY access_timestamp DESC OFFSET 0 ROWS FETCH NEXT @login_attempts ROWS ONLY

			-- Assign value '1' for invalid password or locked account and '0' for others so that login attempts counter can be set to 0 whenever account has been reset
			SELECT @invalid_attempts += CASE WHEN [status] = 'Invalid Password' OR [status] = 'User Account is locked' THEN '1' ELSE '0' END + ','
			FROM #system_access_log

			-- Add char '0' so that substring logic below will not return count 0 when all selected login attempts have status invalid password or user account locked
			SET @invalid_attempts += '0'

			-- Reset login attempt counter to 0 if account has been reset and count exact login attempts after password reset
			SELECT @invalid_attempts_count = COUNT(item)
			FROM dbo.FNASplit(SUBSTRING(@invalid_attempts, 0, CHARINDEX('0', @invalid_attempts, 0)), ',')
			WHERE item = 1

			IF dbo. FNASecurityAdminRoleCheck(@user_login_id) = 0
				AND dbo. FNAAppAdminRoleCheck(@user_login_id) = 0 
				AND @user_login_id <> dbo.FNAAppAdminID()
				AND ( @invalid_attempts_count >= @login_attempts -- Login attempt limits has been reached
					  OR @invalid_attempts_count = @login_attempts - 1 -- Account is one step away from being locked
					)
			BEGIN
				IF @invalid_attempts_count = @login_attempts - 1
				BEGIN
					INSERT INTO #final_status
					SELECT 'Last attempt to login. Your account will be locked if this attempt is unsuccessful.', 'Please try again.'
				END
				ELSE
				BEGIN
					UPDATE application_users
					SET lock_account='y'
					WHERE user_login_id=@user_login_id
		
					IF @@ERROR<>0
						INSERT INTO #final_status
						SELECT 'Failed to update locked user.', ''
					ELSE
					BEGIN
						IF @cloud_mode = 0
						BEGIN
							INSERT INTO #final_status
							SELECT 'Your account has been locked. Please contact the administrator to unlock your account.', 'Please try again.'	
						END
						ELSE
						BEGIN
							INSERT INTO #final_status
							SELECT 'Your account has been locked due to maximum number of unsuccessful login attempts. To restore your access, please reset your password by clicking on ''Forgot Password'' below.', 'Please try again.'							
						END	
					END
				END
			END
			ELSE 
			BEGIN
				INSERT INTO #final_status
				SELECT 'The password is invalid.', 'Please try again.'
			END
			
			SELECT 'Error' [ErrorCode]
				 , 'Appliction User' [Module]
				 , 'spa_is_valid_user' [Area]
				 , 'Security Error' [Status]
				 , [message] [Message]
				 , [recommendation] [Recommendation]
				 , @exceeded_logins [ExceededLogins]
				 , @temp_pwd [TemporaryPassword]
			FROM #final_status
			
		END
	END
END