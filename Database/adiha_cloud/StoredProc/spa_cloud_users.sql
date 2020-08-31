IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_cloud_users]') AND type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_cloud_users]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/**
	Stored Procedure that performs CRUD operations of application_users, company_catalog, license, license_agreement, recovery _password_log and system_access_log table

	Parameters 
	@flag : 's' Select user information including application database connection information with reference to user email address
			'c' Check the email address availability
			'i' Insert new SaaS user
			'u' Update existing SaaS user
			'd' Delete existing SaaS user
			'l' Insert license agreement status
			'p' Insert prospect user in application users table after user registers for demo
			'a' Change Password
			'b' Check if password is matched and get user details like user_login_id,first_name, last_name, user_type
			'e' Get the application name for the provided email address (ARB case)
			'n' Return new user_login_id for SaaS users
			'x' Return user_login_id by user_email_add
			'j' Insert user login success data to system access log after OTP Verfication to avoid showing OTP Verification every time
			'r' Reset pwd for prospect and other (non-saas) users
			'f' Insert data in password recovery table to check if token is valid later on
			't' Check if recovery password token is valid
			'o' Check if recovery password token is valid and update confirmation accepted to 'Y' so that it will not be re-usable
			'm' Check if user email is already registered
			'q' Identify user_login_id by email_address
	@user_email_address : User email address
	@user_password : User password
	@user_login_id : User login ID
	@user_f_name : User First Name
	@user_l_name : User Last Name
	@database_name : Database Name for the user
	@agreement_status : License agreement approval/rejection status
	@system_name : System name
	@system_address : IP address
	@cookie_hash : Multi Factor Authentication ID (MFAID) token stored in client browser for identification
	@agreement_type : Agreement type
	@db_server_name : Database server name
	@token : Recovery token
	@temp_pwd : Temporary password
	@output_result : Output result
*/

CREATE PROC [dbo].[spa_cloud_users]
	@flag CHAR(1),
	@user_email_address VARCHAR(128) = NULL,
	@user_password VARCHAR(128) = NULL,
	@user_login_id NVARCHAR(100) = NULL,
	@user_f_name NVARCHAR(100) = NULL,
	@user_l_name NVARCHAR(100) = NULL,
	@database_name NVARCHAR(100) = NULL,
	@agreement_status NCHAR(1) = NULL,
	@system_name NVARCHAR(100) = NULL,
	@system_address NVARCHAR(100) = NULL,
	@cookie_hash NVARCHAR(100) = NULL,
	@agreement_type NVARCHAR(50) = NULL,
	@db_server_name NVARCHAR(50) = NULL,
	@token VARCHAR(100) = NULL,
	@temp_pwd CHAR(1) = NULL,
	@user_data_json NVARCHAR(MAX) = NULL,
	@output_result VARCHAR(10) = NULL OUTPUT,
	@aad_tenant_id VARCHAR(200) = NULL
AS

SET NOCOUNT ON

/*
DECLARE @flag CHAR(1),
		@user_email_address VARCHAR(128) = NULL,
		@user_password VARCHAR(128) = NULL

SELECT @flag = 's', @user_email_address = 'achyut@pioneersolutionsglobal.com'
--*/

DECLARE @sql VARCHAR(MAX)
	  , @license_id INT
	  , @user_type INT

-- ## Configuration to allow prospect users to make no. of incorrect login attempts with specified time in hours
DECLARE @login_attempts INT = 3
	  , @access_log_time_range INT = 24
	  , @enable_otp BIT = 0 -- Configuration to enable/disable OTP for Prospect and Other(Non-SaaS) users.
	  , @otp_expiry_days INT = 5 -- Configuration to show OTP to Prospect and Other(Non-SaaS) users who have not logged in since 'X' no. of days.
	  , @cookie_auth VARCHAR(100)

IF @cookie_hash = ''
BEGIN
	SET @cookie_auth = NULL
END
ELSE
BEGIN
	SET @cookie_auth = @cookie_hash
END

-- ## This is broken down because it will be needed by other flags in future.
IF @flag = 's' OR @flag = 'c'
BEGIN
	IF OBJECT_ID(N'tempdb..#cloud_users') IS NOT NULL
		DROP TABLE #cloud_users
	
	CREATE TABLE #cloud_users (user_login_id VARCHAR(64), user_email_address VARCHAR(128), company_catalog_id INT, user_active CHAR(1), lock_account CHAR(1), expire_date DATETIME, application_users_id INT, user_type INT, account_status CHAR(1))

	-- ## Prospect and Other(Non-SaaS) users
	IF EXISTS (SELECT 1 FROM application_users WHERE user_email_add = @user_email_address AND user_type IN (109101, 109103))
	BEGIN
		INSERT INTO #cloud_users(user_login_id, user_email_address, company_catalog_id, user_active, lock_account, expire_date, application_users_id, user_type, account_status)
		SELECT user_login_id, user_email_add, -1, user_active , lock_account, expire_date, application_users_id, user_type, account_status
		FROM application_users 
		WHERE user_email_add = @user_email_address 
			AND user_type IN (109101, 109103)
	END
	-- ## SaaS and Demo users
	ELSE
	BEGIN
		INSERT INTO #cloud_users(user_login_id, user_email_address, company_catalog_id, user_active, lock_account, expire_date, application_users_id, user_type)
		SELECT user_login_id, user_email_add, company_catalog_id, user_active, lock_account, expire_date, application_users_id, user_type
		FROM application_users au 
		WHERE user_email_add = @user_email_address
	END
END
--## Get the user database name and user login id
IF @flag = 's'
BEGIN
	DECLARE @license_version VARCHAR(50)

	IF EXISTS(SELECT 1 FROM #cloud_users WHERE company_catalog_id = -1)
	BEGIN
		DECLARE @status VARCHAR(20)

		SELECT TOP 1 @license_id = license_id
		FROM license
		WHERE license_type_id = 109401
		AND effective_date <= GETDATE()
		ORDER BY effective_date DESC, license_version DESC

		-- Check if user account is inactive, locked or expired
		IF EXISTS (SELECT 1 FROM #cloud_users WHERE user_active = 'n' OR lock_account = 'y' OR expire_date IS NULL OR expire_date < CAST(GETDATE() AS DATE) OR account_status <> 'a')
		BEGIN			
			SELECT @status = CASE WHEN acu.user_active = 'n' THEN 'Inactive' 
							  WHEN acu.lock_account = 'y' THEN 'Locked'
							  WHEN acu.expire_date IS NULL OR acu.expire_date < CAST(GETDATE() AS DATE) THEN 'Expired'
							  WHEN acu.account_status IS NULL OR acu.account_status <> 'a' THEN 'Pending' 
							  ELSE 'Error' END
			FROM #cloud_users acu
			INNER JOIN application_users au ON au.user_login_id = acu.user_login_id
			WHERE acu.user_login_id IS NOT NULL
			
			-- Insert data into system access table to keep track of login attempts made by prospect users
			INSERT INTO system_access_log (user_login_id, access_timestamp, [status], system_name, system_address, cookie_hash)
			SELECT acu.user_email_address, GETDATE(), @status, @system_name, @system_address, @cookie_auth 
			FROM #cloud_users acu
					
			SELECT TOP 1 cc.company_db_name
					   , acu.user_login_id
					   , CASE WHEN acu.user_type = 109101 THEN 'Prospect'
						 ELSE 'Other' END [user_type]
					   , au.user_f_name + ISNULL(' ' + NULLIF(au.user_m_name, ''), '') + ' ' + au.user_l_name [full_name]
					   , @status [status]
					   , la.agreement_status
					   , 0 enable_otp -- Do not enable OTP unless user account is active, unlocked and valid.
			FROM #cloud_users acu
			INNER JOIN application_users au ON au.user_login_id = acu.user_login_id
			LEFT JOIN company_catalog cc ON acu.company_catalog_id = cc.company_catalog_id
			LEFT JOIN license_agreement la ON la.application_users_id = acu.application_users_id AND la.agreement_status = 'a' AND license_id = @license_id
			WHERE acu.user_login_id IS NOT NULL
		END
		ELSE
		BEGIN
			SELECT @user_login_id = acu.user_login_id
				 , @status = IIF(au.user_pwd = @user_password, 'Success', 'Invalid Password')
				 , @user_email_address = au.user_email_add
			FROM #cloud_users acu
			INNER JOIN application_users au ON au.user_login_id = acu.user_login_id
			LEFT JOIN company_catalog cc ON acu.company_catalog_id = cc.company_catalog_id
			WHERE acu.user_login_id IS NOT NULL
			
			-- Enable otp if user login from new device or last login before specified days
			IF EXISTS (
				SELECT 1 
				FROM system_access_log 
				WHERE user_login_id = @user_email_address 
					AND system_name = @system_name 
					AND system_address = @system_address 
					AND DATEDIFF(DAY, access_timestamp , GETDATE()) < @otp_expiry_days 
					AND [status] = 'Success'
					AND cookie_hash = ISNULL(@cookie_auth, 0)
			)
			BEGIN
				SET @enable_otp = 0;
				
				-- Insert data into system access table to keep track of login attempts made by prospect users
				INSERT INTO system_access_log (user_login_id, access_timestamp, [status], system_name, system_address, cookie_hash)
				SELECT acu.user_email_address, GETDATE(), @status, @system_name, @system_address, @cookie_auth 
				FROM #cloud_users acu
			END
			
			-- Count no. of login attempts made by user. If it exceeds more than specified times then lock account
			DECLARE @invalid_password INT
			
			IF OBJECT_ID('tempdb..#system_access_log') IS NOT NULL
				DROP TABLE #system_access_log
			
			SELECT * 
			INTO #system_access_log
			FROM system_access_log
			WHERE access_timestamp BETWEEN DATEADD(HH, -1 * @access_log_time_range, GETDATE()) AND GETDATE()
				AND user_login_id = @user_email_address
			ORDER BY access_timestamp DESC OFFSET 0 ROWS FETCH NEXT @login_attempts ROWS ONLY
			
			SELECT @invalid_password = SUM(CASE WHEN [status] = 'Invalid Password' OR [status] = 'Locked' THEN 1 ELSE 0 END)
			FROM #system_access_log
			
			IF @invalid_password >= @login_attempts
			BEGIN
				UPDATE application_users
				SET lock_account = 'y'
				WHERE user_email_add = @user_email_address
				
				SELECT TOP 1 cc.company_db_name
						   , acu.user_login_id
						   , CASE WHEN acu.user_type = 109101 THEN 'Prospect'
							 ELSE 'Other' END [user_type]
						   , au.user_f_name + ISNULL(' ' + NULLIF(au.user_m_name, ''), '') + ' ' + au.user_l_name [full_name]
						   , 'Locked' [status]
						   , la.agreement_status
						   , 0 enable_otp -- Do not enable OTP unless user account is active, unlocked and valid.
				FROM #cloud_users acu
				INNER JOIN application_users au ON au.user_login_id = acu.user_login_id
				LEFT JOIN company_catalog cc ON acu.company_catalog_id = cc.company_catalog_id
				LEFT JOIN license_agreement la ON la.application_users_id = acu.application_users_id AND la.agreement_status = 'a' AND license_id = @license_id
				WHERE acu.user_login_id IS NOT NULL
				
				-- Insert data into system access table to keep track of login attempts made by prospect users
				INSERT INTO system_access_log (user_login_id, access_timestamp, [status], system_name, system_address, cookie_hash)
				SELECT acu.user_email_address, GETDATE(), 'Locked', @system_name, @system_address, @cookie_auth 
				FROM #cloud_users acu
				
				RETURN
			END
			
			SELECT TOP 1 cc.company_db_name
					   , acu.user_login_id
					   , CASE WHEN acu.user_type = 109101 THEN 'Prospect'
						 ELSE 'Other' END [user_type]
					   , au.user_f_name + ISNULL(' ' + NULLIF(au.user_m_name, ''), '') + ' ' + au.user_l_name [full_name]
					   , IIF(au.user_pwd = @user_password, 'Success', 'Error') [status]
					   , la.agreement_status
					   , @enable_otp [enable_otp]
			FROM #cloud_users acu
			INNER JOIN application_users au ON au.user_login_id = acu.user_login_id
			LEFT JOIN company_catalog cc ON acu.company_catalog_id = cc.company_catalog_id
			LEFT JOIN license_agreement la ON la.application_users_id = acu.application_users_id AND la.agreement_status = 'a' AND license_id = @license_id
			WHERE acu.user_login_id IS NOT NULL
		END
	END
	ELSE
	BEGIN
		DECLARE @company_catalog_id INT

		SELECT @user_type = acu.user_type
			 , @company_catalog_id = acu.company_catalog_id
		FROM #cloud_users acu
		INNER JOIN company_catalog cc
			ON cc.company_catalog_id = acu.company_catalog_id

		SELECT TOP 1 @license_id = license_id
		FROM license
		WHERE license_type_id = 109400
		AND effective_date <= GETDATE()
		ORDER BY effective_date DESC, license_version DESC

		IF @user_type = 109100
		BEGIN
			IF OBJECT_ID(N'tempdb..#company_info') IS NOT NULL
				DROP TABLE #company_info

			CREATE TABLE #company_info (
				  counterparty_id VARCHAR(50)
				, counterparty_name VARCHAR(50)
				, contract_end_date DATETIME
			)

			SET @sql = '
			IF EXISTS (
				SELECT 1 
				FROM fn_my_permissions(''' + @database_name + '.dbo.application_users'', ''OBJECT'')
				WHERE permission_name = ''SELECT''
			)
			BEGIN
				INSERT INTO #company_info (
					  counterparty_id
					, counterparty_name
					, contract_end_date
				)
				SELECT sc.counterparty_id
					 , sc.counterparty_name
					 , scca.contract_end_date
				FROM [' + @database_name + '].[dbo].[source_counterparty] sc
				INNER JOIN [' + @database_name + '].[dbo].[counterparty_contract_address] scca
					ON scca.counterparty_id = sc.source_counterparty_id
				WHERE sc.counterparty_id = CAST(' + CAST(@company_catalog_id AS VARCHAR(10)) + ' AS VARCHAR(50))
			END'

			EXEC (@sql)

			SELECT TOP 1 cc.company_db_name
					   , acu.user_login_id
					   , 'SaaS' [user_type]
					   , cc.db_server_name [db_server_name]
					   , la.agreement_status
					   , CASE WHEN ci.contract_end_date < CAST(GETDATE() AS DATE) THEN 'y' ELSE 'n' END license_expired
					   , cc.db_user
					   , dbo.FNADecrypt(cc.db_pwd) [db_pwd]
					   , cc.app_name [application_name]
					   , CASE WHEN ISNULL(cc.aad_tenant_id, @aad_tenant_id) IS NULL
									THEN 'authorized'
							  WHEN cc.aad_tenant_id <> @aad_tenant_id
									THEN 'unauthorized'
						 END [aad_tenant]
			FROM #cloud_users acu
			INNER JOIN company_catalog cc ON acu.company_catalog_id = cc.company_catalog_id
			LEFT JOIN #company_info ci ON ci.counterparty_id = cc.company_catalog_id
			LEFT JOIN license_agreement la ON la.application_users_id = acu.application_users_id AND la.agreement_status = 'a' AND license_id = @license_id
			WHERE acu.user_login_id IS NOT NULL
		END
		ELSE
		BEGIN
			SELECT TOP 1 cc.company_db_name
					   , acu.user_login_id
					   , 'Demo' [user_type]
					   , cc.db_server_name [db_server_name]
					   , la.agreement_status
					   , CASE WHEN expire_date < CAST(GETDATE() AS DATE) THEN 'y' ELSE 'n' END license_expired
					   , cc.db_user
					   , dbo.FNADecrypt(cc.db_pwd) [db_pwd]
					   , cc.app_name [application_name]
					   , CASE WHEN ISNULL(cc.aad_tenant_id, @aad_tenant_id) IS NULL
									THEN 'Authorized'
							  WHEN cc.aad_tenant_id <> @aad_tenant_id
									THEN 'Unauthorized'
						 END [aad_tenant]
			FROM #cloud_users acu
			INNER JOIN company_catalog cc ON acu.company_catalog_id = cc.company_catalog_id
			LEFT JOIN license_agreement la ON la.application_users_id = acu.application_users_id AND la.agreement_status = 'a' AND license_id = @license_id
			WHERE acu.user_login_id IS NOT NULL
		END
	END
END
--## Check the email address availability
ELSE IF @flag = 'c'
BEGIN
	IF EXISTS(
		SELECT user_login_id 
		FROM #cloud_users
		WHERE user_email_address = @user_email_address)
	BEGIN
		SET @output_result = 0 -- Unavailable already used
	END
	ELSE
	BEGIN
		SET @output_result = 1 -- Available
	END
END
--## INSERT/UPDATE user
ELSE IF @flag = 'i'
BEGIN
	DECLARE @catalog_id INT

	IF EXISTS (SELECT 1 FROM company_catalog WHERE company_db_name = @database_name AND db_server_name IS NULL)
	BEGIN
		IF EXISTS (SELECT 1 FROM company_catalog WHERE company_db_name = @database_name AND db_server_name = @db_server_name)
		BEGIN
			SELECT @catalog_id = company_catalog_id 
			FROM company_catalog
			WHERE company_db_name = @database_name
				AND db_server_name = @db_server_name
		END
		ELSE
		BEGIN
			SELECT @catalog_id = company_catalog_id
			FROM company_catalog
			WHERE company_db_name = @database_name
				AND db_server_name IS NULL
		END
	END
	ELSE
	BEGIN
		SELECT @catalog_id = company_catalog_id
		FROM company_catalog
		WHERE company_db_name = @database_name
			AND db_server_name = @db_server_name
	END

	IF EXISTS ( SELECT 1
				FROM application_users
				WHERE user_email_add = @user_email_address
					AND user_login_id <> @user_login_id )
	BEGIN
		SELECT 'Not Available' ErrorCode
	END
	ELSE IF EXISTS (
		SELECT 1 
		FROM application_users au
		INNER JOIN company_catalog cc 
			ON cc.company_catalog_id = au.company_catalog_id
		WHERE au.user_login_id = @user_login_id 
			AND cc.company_db_name = @database_name 
			AND CHECKSUM(au.user_f_name, ISNULL(au.user_l_name,''), ISNULL(au.user_email_add,'')) <> CHECKSUM(@user_f_name, ISNULL(@user_l_name, ''), ISNULL(@user_email_address, '')))
	BEGIN
		UPDATE au
		SET au.user_f_name = @user_f_name
		  , au.user_l_name = @user_l_name
		  , au.user_email_add = @user_email_address
		FROM application_users au
		INNER JOIN company_catalog cc 
			ON cc.company_catalog_id = au.company_catalog_id
		WHERE au.user_login_id = @user_login_id 
			AND cc.company_db_name = @database_name

		SELECT 'User updated' ErrorCode
	END
	ELSE IF NOT EXISTS ( SELECT 1
					FROM application_users
					WHERE user_email_add = @user_email_address )
	BEGIN
		INSERT INTO application_users(user_login_id, user_f_name, user_l_name, user_pwd, user_email_add, company_catalog_id, user_type)
		SELECT @user_login_id, @user_f_name, @user_l_name, '', @user_email_address, @catalog_id, 109100
		WHERE @user_email_address <> ''
			AND @user_login_id <> ''

		SELECT 'User created' ErrorCode
	END
END

--## UPDATE user
ELSE IF @flag = 'u'
BEGIN
	IF EXISTS(
		SELECT 1 
		FROM application_users au
		INNER JOIN company_catalog cc ON cc.company_catalog_id = au.company_catalog_id
		WHERE au.user_login_id = @user_login_id AND cc.company_db_name = @database_name 
		AND CHECKSUM(au.user_f_name,ISNULL(au.user_l_name,''),ISNULL(au.user_email_add,'')) <>  CHECKSUM(@user_f_name,ISNULL(@user_l_name,''),ISNULL(@user_email_address,'')))
	BEGIN
		UPDATE au
			SET au.user_f_name = @user_f_name, 
				au.user_l_name = @user_l_name, 
				au.user_email_add = @user_email_address
		FROM
		application_users au
		INNER JOIN company_catalog cc ON cc.company_catalog_id = au.company_catalog_id
		WHERE au.user_login_id = @user_login_id AND cc.company_db_name = @database_name
	    
		SELECT 1 ErrorCode
	END
	ELSE
	BEGIN
		SELECT 0 ErrorCode
	END
END

--## DELETE user
ELSE IF @flag = 'd'
BEGIN
	IF @user_data_json IS NOT NULL
	BEGIN
		DELETE la
		FROM license_agreement la
		INNER JOIN application_users au
			ON au.application_users_id = la.application_users_id
		INNER JOIN dbo.FNAParseJSON(@user_data_json) del
			ON del.stringvalue = au.user_email_add

		DELETE au
		FROM application_users au
		INNER JOIN dbo.FNAParseJSON(@user_data_json) del
			ON del.stringvalue = au.user_email_add

		SELECT 'Users deleted' ErrorCode
	END
	ELSE IF EXISTS (
		SELECT 1 
		FROM application_users
		WHERE user_email_add = @user_email_address )
	BEGIN
		DELETE la
		FROM license_agreement la
		INNER JOIN application_users au
			ON au.application_users_id = la.application_users_id
		WHERE au.user_email_add = @user_email_address

		DELETE FROM
		application_users
		WHERE user_email_add = @user_email_address

		SELECT 'User deleted' ErrorCode
	END
	ELSE
	BEGIN
		SELECT 'User not found' ErrorCode
	END
END

--## Insert license agreement status
ELSE IF @flag = 'l'
BEGIN
	IF EXISTS (SELECT 1 FROM application_users WHERE user_email_add = @user_email_address)
	BEGIN
		SELECT @user_type = user_type
		FROM application_users
		WHERE user_email_add = @user_email_address

		SELECT TOP 1 @license_id = license_id
		FROM license
		WHERE license_type_id = CASE WHEN @user_type IN (109100,109102) THEN 109400
								ELSE 109401 END
		AND effective_date <= GETDATE()
		ORDER BY effective_date DESC, create_ts DESC

		INSERT INTO license_agreement (
			  application_users_id
			, agreement_status
			, license_date
			, license_id
		)
		SELECT au.application_users_id
			 , @agreement_status
			 , GETDATE()
			 , @license_id
		FROM application_users au
		WHERE au.user_email_add = @user_email_address

		SELECT 'Success' AS ErrorCode 
	END
END

-- Insert prospect user in application users table after user registers for demo
ELSE IF @flag = 'p'
BEGIN
	BEGIN TRY
		BEGIN TRAN
		IF NOT EXISTS (SELECT 1 FROM application_users WHERE user_email_add = @user_email_address)
		BEGIN
			INSERT INTO application_users  (
				user_login_id
			  , user_f_name
			  , user_l_name
			  , user_pwd
			  , user_email_add
			  , expire_date
			  , account_status
			  , user_type
			  , user_active
			  , lock_account
			)
			SELECT 'p_user_' + @user_login_id
				 , @user_f_name
				 , @user_l_name
				 , @user_password
				 , @user_email_address
				 , DATEADD(DAY, 7, GETDATE())
				 , 'p' -- Pending
				 , 109101 -- Prospect User Type
				 , 'y'
				 , 'n'
			SELECT 'Success' AS ErrorCode
		END
		ELSE
		BEGIN
			SELECT 'Error' AS ErrorCode
		END		
		COMMIT
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS ErrorCode
	END CATCH
END

-- Change Password
ELSE IF @flag = 'a'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			UPDATE application_users
			SET user_pwd = @user_password
			WHERE user_email_add = @user_email_address
			SELECT 'Success' AS ErrorCode
		COMMIT
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS ErrorCode
	END CATCH
END

-- Check if password is matched and get user details like user_login_id,first_name, last_name, user_type
ELSE IF @flag = 'b'
BEGIN
	SELECT user_login_id
		 , user_f_name
		 , user_l_name
		 , CASE WHEN user_type = 109100 THEN 'SaaS'
				WHEN  user_type = 109101 THEN 'Prospect'
				WHEN  user_type = 109102 THEN 'Demo'
				ELSE 'Other'END user_type
		, IIF(user_pwd = @user_password, 'y', 'n') match_pwd
	FROM application_users
	WHERE user_email_add = @user_email_address
END
--## Get the application name for the provided email address (ARB case)
ELSE IF @flag = 'e'
BEGIN
    SELECT cc.[app_name]
		 , cc.[company_catalog_id]
		 , CASE WHEN au.user_type = 109100 THEN 'SaaS'
				WHEN au.user_type = 109101 THEN 'Prospect'
				WHEN au.user_type = 109102 THEN 'Demo'
				ELSE 'Other'END [user_type]
		 , au.user_login_id
		 , cc.aad_tenant_id
    FROM company_catalog cc
    INNER JOIN application_users au ON au.company_catalog_id = cc.company_catalog_id
    WHERE au.user_email_add = @user_email_address
END

-- Return new user_login_id for SaaS users
ELSE IF @flag = 'n'
BEGIN
	SELECT CAST((IDENT_CURRENT('application_users') + 1) AS VARCHAR(100)) [user_login_id]
END

-- Return user_login_id by user_email_add
ELSE IF @flag = 'x'
BEGIN
	SELECT user_login_id
		 , user_type
	FROM application_users 
	WHERE user_email_add = @user_email_address
END

-- Insert user login success data to system access log after OTP Verfication to avoid showing OTP Verification every time
ELSE IF @flag = 'j'
BEGIN
	INSERT INTO system_access_log (user_login_id, access_timestamp, [status], system_name, system_address, cookie_hash)
	SELECT @user_email_address, GETDATE(), 'Success', @system_name, @system_address, @cookie_auth
END

-- Reset pwd for prospect and other (non-saas) users
ELSE IF @flag = 'r'
BEGIN
	IF EXISTS (SELECT 1 FROM application_users WHERE user_email_add = @user_email_address)
	BEGIN		
		IF @token <> NULL OR @token <> ''
		BEGIN
			IF EXISTS (SELECT 1 FROM application_users WHERE user_pwd = @user_password AND user_email_add = @user_email_address)
			BEGIN
				SELECT 'Error' AS [status]
					 , 'You are not allowed to reuse your previous password.' AS [msg]
					 , user_f_name
					 , user_l_name
				FROM application_users
				WHERE user_email_add = @user_email_address

				RETURN	
			END
			
			UPDATE application_users
			SET user_pwd = @user_password
			  , temp_pwd = CASE WHEN @temp_pwd IS NULL OR @temp_pwd = 'y' THEN 'y' -- Set temporary password to true to force user to change password upon first login using new password generated by the system
								ELSE 'n' END 
			WHERE user_email_add = @user_email_address

			UPDATE recovery_password_log
			SET confirmation_accepted = 'Y'
			WHERE request_email_address = @user_email_address
			AND recovery_password_confirmation_id = @token
		END
		ELSE
		BEGIN
			UPDATE application_users
			SET user_pwd = @user_password
			  , temp_pwd = CASE WHEN @temp_pwd IS NULL OR @temp_pwd = 'y' THEN 'y' -- Set temporary password to true to force user to change password upon first login using new password generated by the system
								ELSE 'n' END 
			WHERE user_email_add = @user_email_address
		END	

		SELECT 'Success' AS [status]
			 , 'Password has been changed successfully.' AS [msg]
	END
	ELSE
	BEGIN
		SELECT 'Error' AS [status]
			 , 'The username does not exist either in application or in database.' AS [msg]
	END
END

-- Insert data in password recovery table to check if token is valid later on
ELSE IF @flag = 'f'
BEGIN
	IF EXISTS (SELECT 1 FROM application_users WHERE user_email_add = @user_email_address)
	BEGIN
		IF EXISTS (SELECT 1 FROM recovery_password_log WHERE recovery_password_confirmation_id = @token)
		BEGIN
			SELECT 'Duplicate Token' AS ErrorCode
			 , '' AS user_type
			 , '' AS [app_name]
			RETURN
		END

		INSERT INTO recovery_password_log (
			  request_email_address
			, user_login_id
			, request_date
			, recovery_password_confirmation_id
			, confirmation_accepted
		)
		SELECT user_email_add
			 , user_login_id
			 , GETDATE()
			 , @token
			 , 'N'
		FROM application_users
		WHERE user_email_add = @user_email_address

		SELECT 'Success' AS ErrorCode
			 , CASE WHEN au.user_type = 109100 THEN 'SaaS'
			   WHEN  au.user_type = 109101 THEN 'Prospect'
			   WHEN  au.user_type = 109102 THEN 'Demo'
			   ELSE 'Other' END user_type
			 , ISNULL(cc.[app_name], '') [app_name]
		FROM application_users au
		LEFT JOIN company_catalog cc
			ON cc.company_catalog_id = au.company_catalog_id
		WHERE user_email_add = @user_email_address
	END
	ELSE
	BEGIN
		SELECT 'Failed' AS ErrorCode
			 , '' AS user_type
			 , '' AS [app_name]
	END
END

-- Check if recovery password token is valid
ELSE IF @flag = 't' OR @flag = 'o'
BEGIN
	IF EXISTS (SELECT 1 FROM recovery_password_log WHERE request_email_address = @user_email_address AND recovery_password_confirmation_id = @token AND confirmation_accepted = 'N' AND ABS(DATEDIFF(HOUR, GETDATE(), request_date)) <= 24)
	BEGIN
		-- Expire token
		IF @flag = 'o'
		BEGIN
			UPDATE recovery_password_log
			SET confirmation_accepted = 'Y'
			WHERE request_email_address = @user_email_address
				AND recovery_password_confirmation_id = @token
		END

		SELECT 'Valid' AS ErrorCode
	END
	ELSE
	BEGIN
		SELECT 'Invalid' AS ErrorCode
	END
END

-- Check if user email is already registered
ELSE IF @flag = 'm'
BEGIN
	IF EXISTS ( SELECT 1 
				FROM application_users
				WHERE user_email_add = @user_email_address
					AND user_login_id <> @user_login_id )
	BEGIN
		SELECT 'Not Available' ErrorCode -- Unavailable already used
	END
	ELSE
	BEGIN	
		SELECT 'Available' ErrorCode -- Available	
	END
END

-- Identify user_login_id by email_address
ELSE IF @flag = 'q'
BEGIN
	SELECT user_login_id
		 , user_f_name
		 , user_l_name
	FROM application_users
	WHERE user_email_add = @user_email_address
END
GO