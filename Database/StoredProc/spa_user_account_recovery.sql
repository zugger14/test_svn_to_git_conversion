IF OBJECT_ID('spa_user_account_recovery') IS NOT NULL
DROP PROC [dbo].[spa_user_account_recovery]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

/**
	Stored Procedure to reset password of application users

	Parameters	
	@flag : 'r' Check the existance of email address and reset password
			'c' Check the existance of password reset confirmation id and complete reset process
			'l' Return login id related to recovery id
			'p' Change Password for SaaS user. Used in reset password logic from website.
	@user_email : Email address of the application user
	@recovery_id : Unique recovery ID to reset user password
	@confirmation_accepted : 'Y' if user has accepted password reset confirmation else 'N'
	@password_suggested: System suggested user password
	@url: Password reset link
	@phpEncPwd : Encrypted Password
	@call_from : Call from 
	@is_cloud_mode : '1' if cloud mode is turned on else '0'
	@pwd_expiry_days : Password expiry days for current set password
*/

CREATE PROCEDURE [dbo].[spa_user_account_recovery]
	@flag char(1),
	@user_email VARCHAR(150) = NULL,
	@recovery_id VARCHAR(100) = NULL,
	@confirmation_accepted CHAR(1) = 'N',
	@password_suggested VARCHAR(5) = NULL,
	@url VARCHAR(1000) = NULL,
	@phpEncPwd VARCHAR(50) = NULL,
	@call_from VARCHAR(50) = NULL,
	@is_cloud_mode CHAR(1) = 'n',
	@pwd_expiry_days INT = 90
AS

SET NOCOUNT ON

DECLARE @error_no INT
-- ## Check the existance of email address and reset password
IF @flag = 'r'
BEGIN
	IF EXISTS(SELECT user_emal_add FROM application_users WHERE user_emal_add = @user_email)
	BEGIN
		BEGIN TRY
			BEGIN TRAN

			DECLARE @user_login_id VARCHAR(64)
			SELECT @user_login_id = user_login_id FROM application_users WHERE user_emal_add = @user_email
			
			-- ## Insert the log of password reset request
			INSERT INTO recovery_password_log (	request_email_address
												, user_login_id
												, request_date
												, recovery_password_confirmation_id
												, confirmation_accepted
												, password_suggested)
			VALUES(@user_email, @user_login_id, GETDATE(), @recovery_id, @confirmation_accepted, @password_suggested)

			-- ## Send Email with confirmation link
			DECLARE @notes_subject VARCHAR(256), @notes_text VARCHAR(5000),
				@send_from VARCHAR(100), @send_to VARCHAR(100), @send_bcc VARCHAR(100)

			SET @notes_subject = 'Account Recovery Confirmation'
			SET @notes_text = '<font size="2" face="Verdana, Arial, Helvetica, sans-serif">To initiate the password reset process for your account, <a href="'+@url+'adiha.login.screen/user.account.recovery.php?call_from='+@call_from+'&confirmID='+ @recovery_id +'&user_email='+@user_email+'"><i>Click Here</i></a>&nbsp; <p>If you''ve received this mail in error, it''s likely that another user entered your email address by mistake while trying to reset a password. If you didn''t initiate the request, you don''t need to take any further action and can safely disregard this email.</p> <P>Thank you.</p></font>'
			
			SET @send_from = 'noreply@pioneersolutionsglobal.com'
			SET @send_to = @user_email
			SET @send_bcc = @send_from
			
			EXEC [spa_email_notes] @flag = 'e', 
				@internal_type_value_id = 27,
				@notes_object_name = 'na',
				@notes_object_id = 'na',
				@send_from = @send_from,
				@send_to = @send_to, 
				@send_bcc = @send_bcc,
				@send_status = 'n', 
				@active_flag = 'y', 
				@email_subject = @notes_subject, 
				@notes_text = @notes_text
			
			COMMIT

			EXEC spa_ErrorHandler 0, 'Password Reset', 
							'spa_user_account_recovery', 'Success', 
							'An email has been sent to your email address.<br/><br/>To get back into your account, follow the instructions we''ve sent to your email address.<br/><br/>Didn''t receive the password reset email? Check your spam folder for an email. If you still don''t see the email, consult with your administrator.',
							''
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK

			SET @error_no = ERROR_NUMBER()
			EXEC spa_ErrorHandler @error_no, 'Password Reset', 
					'spa_user_account_recovery',
					'Error', 
					'Unable to send Username/Password Recovery email confirmation.<br/> Please contact your System Administrator.',
					''
		END CATCH
	END
	ELSE
	BEGIN
		EXEC spa_ErrorHandler 1, 'Password Reset', 
				'spa_user_account_recovery',
				'Error', 
				'The email address does not exist in the system.',
				''
	END
END
--## Check the existance of password reset confirmation id and complete reset process
ELSE IF @flag = 'c'
BEGIN
	--## Check if password reset link is valid
	IF EXISTS (SELECT recovery_password_confirmation_id FROM recovery_password_log WHERE recovery_password_confirmation_id = @recovery_id)
	BEGIN
	--## Check if password already reset with the reset link
		IF NOT EXISTS (SELECT recovery_password_confirmation_id 
					FROM recovery_password_log 
					WHERE recovery_password_confirmation_id = @recovery_id AND confirmation_accepted='y')
		BEGIN
			BEGIN TRY
				BEGIN TRAN

				DECLARE @to_Email VARCHAR(64)
				SELECT @user_login_id = user_login_id FROM recovery_password_log WHERE recovery_password_confirmation_id = @recovery_id
				SELECT @user_email = user_emal_add FROM application_users WHERE user_login_id = @user_login_id

				--## Mark reset request as completed
				UPDATE recovery_password_log
					SET password_suggested = @password_suggested,
						confirmation_accepted = 'y'
				WHERE recovery_password_confirmation_id = @recovery_id

				--## Update the User Password in application_users table
				UPDATE application_users
					SET user_pwd = @phpEncPwd,
						temp_pwd = 'y'
				WHERE user_login_id = @user_login_id

				--## Email New Login Information
				SELECT @to_Email = request_email_address FROM recovery_password_log WHERE recovery_password_confirmation_id = @recovery_id
				
				SET @notes_subject = 'New Recovery Account Information'
				SET @notes_text = '<font size="2" face="Verdana, Arial, Helvetica, sans-serif">You have successfully reset your password. Please use the following login credential:<P>' + IIF(@is_cloud_mode = 'y', '<b>Email: </b>' + @to_Email, '<b>User Name: </b>' + @user_login_id) + '<BR><b>New Password: </b>'+@password_suggested+'<BR><BR><a href="' + @url + '">Click here</a> to return to the login page.<BR><BR>Thank you.</font>'
				
				SET @send_from ='noreply@pioneersolutionsglobal.com'
				SET @send_to = @to_Email
				SET @send_bcc = @send_from
								
				EXEC [spa_email_notes] @flag = 'e', 
					@internal_type_value_id = 27,
					@notes_object_name = 'na',
					@notes_object_id = 'na',
					@send_from = @send_from,
					@send_to = @send_to, 
					@send_bcc = @send_bcc,
					@send_status = 'n', 
					@active_flag = 'y', 
					@email_subject = @notes_subject, 
					@notes_text = @notes_text
					
				-- Avoid locking user account on first attempt when user inputs incorrect password. Also make sure user account is not locked
				IF @is_cloud_mode = 'n'
				BEGIN
					EXEC spa_system_access_log 'i', @user_login_id, '', '', 'Password Reset'
				END
				ELSE
				BEGIN
					EXEC spa_system_access_log 'i', @user_email, '', '', 'Password Reset'
				END
					
				
				IF EXISTS (SELECT 1 FROM application_users WHERE user_login_id = @user_login_id AND lock_account = 'y')
				BEGIN
					UPDATE application_users
					SET lock_account = 'n'
					WHERE user_login_id = @user_login_id
				END
				

				COMMIT
				EXEC spa_ErrorHandler 0, 'Password Reset',
								'spa_user_account_recovery', 'Success',
								'Password has been successfully reset.',''
			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK

				SET @error_no = ERROR_NUMBER()
				EXEC spa_ErrorHandler @error_no, 'Password Reset',
								'spa_user_account_recovery', 'Error',
								'Failed to reset password.', ''
			END CATCH
		END
		ELSE
		BEGIN
			SELECT 'Duplicate' AS ErrorCode
		END
	END
	ELSE
	BEGIN
		EXEC spa_ErrorHandler 1, 'The Account Recovery Confirmation ID does not exist.',
				'spa_user_account_recovery', 'Message Box Information',
				'Checked for Recovery Confirmation ID', ''
	END
END
ELSE IF @flag = 'l' --## Return login id related to recovery id
BEGIN
	--## Check if password reset link is valid
	IF EXISTS (SELECT recovery_password_confirmation_id FROM recovery_password_log WHERE recovery_password_confirmation_id = @recovery_id)
	BEGIN
		SELECT LOWER(user_login_id)
		FROM recovery_password_log
		WHERE recovery_password_confirmation_id = @recovery_id
	END
END
-- Reset Password for SaaS user. Used in reset password logic from website.
ELSE IF @flag = 'p'
BEGIN
	DECLARE @old_pwd NVARCHAR(50)

	SELECT @old_pwd = user_pwd 
	FROM application_users WHERE user_emal_add = @user_email

	IF (@old_pwd <> @phpEncPwd)
	AND NOT EXISTS ( SELECT 1 
						FROM (
							SELECT TOP(4) log.user_pwd
							FROM application_users_password_log log
							INNER JOIN application_users au
								ON au.user_login_id = log.user_login_id
							WHERE au.user_emal_add = @user_email
							ORDER BY log.as_of_date DESC
						) historical_pwd
						WHERE historical_pwd.user_pwd = @phpEncPwd )
	BEGIN
		UPDATE application_users
		SET user_pwd = @phpEncPwd
			, temp_pwd = 'n'
			, expire_date = DATEADD(DD, @pwd_expiry_days, GETDATE())
			, lock_account = 'n' -- To make sure user account is not locked after reset password
		WHERE user_emal_add = @user_email

		INSERT INTO application_users_password_log (
			user_login_id
			, as_of_date
			, user_pwd
		)
		SELECT user_login_id
				, GETDATE()
				, @phpEncPwd
		FROM application_users
		WHERE user_emal_add = @user_email

		-- Avoid locking user account on first attempt when user inputs incorrect password. Also make sure user account is not locked
		EXEC spa_system_access_log 'i', @user_email, '', '', 'Password Reset'

		SELECT 'Success' AS [ErrorCode]
			 , 'Your password has been reset successfully.' AS [Message]
	END
	ELSE
	BEGIN
		SELECT 'Error' AS [ErrorCode]
			 , 'You are not allowed to reuse your previous four password.' AS [Message]
	END
END