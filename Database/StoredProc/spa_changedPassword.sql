IF EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[spa_changedPassword]') AND [type] IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_changedPassword]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_changedPassword]
	@user_login_id VARCHAR(50) ,
	@user_pwd VARCHAR(50)=NULL ,
	@temp_pwd CHAR(1)='y',
	@expire_date VARCHAR(20),
	@reuse_count int=4, -- changed to 4 to check previous four password
	@old_password VARCHAR(50)=NULL,
	@user_admin CHAR(1)=null,
	@pwd_raw VARCHAR(50) = NULL,
	@cloud_mode BIT = 0
AS

/*******************************************
DECLARE @user_login_id VARCHAR(50) ,
		@user_pwd VARCHAR(50)=NULL ,
		@temp_pwd CHAR(1)='y',
		@expire_date VARCHAR(20),
		@reuse_count int=4, -- changed to 4 to check previous four password
		@old_password VARCHAR(50)=NULL,
		@user_admin CHAR(1)=null,
		@pwd_raw VARCHAR(50) = NULL,
		@cloud_mode BIT = 0
SELECT @user_login_id='release_6246',@user_pwd='reIcvExEcbfek',@temp_pwd='y',@expire_date='05/27/2018',@old_password='re/pgshduiDmI',@user_admin='1',@pwd_raw='release1'
--*****************************************/

SET NOCOUNT ON

BEGIN	
	DECLARE @logged_user VARCHAR(100)
	SELECT @logged_user = dbo.FNAdbuser()

	--Check if old pwd is correct if user is trying to change pwd of self
	IF(@user_admin = '0' OR (@user_admin='1' AND @logged_user = @user_login_id))
	BEGIN
		IF @reuse_count > 0
		BEGIN
			DECLARE @sqlStmt VARCHAR(5000)
			
			IF NOT EXISTS(SELECT 1 FROM application_users WHERE user_pwd = @old_password AND user_login_id = @user_login_id)
			BEGIN
				EXEC spa_Errorhandler -1, 'Password Change', 'spa_changedPassword', 'DB Error', 'The old password you have entered is incorrect.', ''				
				RETURN
			END
		END
	END
		
	IF (@reuse_count > 0 AND (@user_admin = '0' OR (@user_admin = '1' AND @logged_user = @user_login_id))) --when user is changing pwd of self
		AND ((@user_pwd = @old_password) --check if new pwd is same as old one
		 OR EXISTS (SELECT 1 FROM (
						SELECT TOP(@reuse_count - 1) * 
						FROM application_users_password_log
						WHERE user_login_id = @user_login_id
						ORDER BY as_of_date DESC
					) historical_pwd
					WHERE historical_pwd.user_pwd = @user_pwd --check if new pwd has been used previously
	    ))
	BEGIN
		SELECT 'Error' ErrorCode, 'Password Log' Module, 'spa_application_password_log' Area, 'Error' [Status], 'You are not allowed to reuse your previous four password. Please enter a new one.' Message, '' Recommendation
	END
	ELSE
	BEGIN --validation passed, now change the password
		UPDATE application_users 
		SET user_pwd = @user_pwd,	--PHPEnc
		    temp_pwd = @temp_pwd,
		    expire_date = DATEADD(dd, -1, @expire_date) -- since the creation day also should be counted
		WHERE  user_login_id = @user_login_id
		
		-- unlock user
		UPDATE application_users 
		SET lock_account = 'n' 
		WHERE user_login_id = @user_login_id
		
		--if admin is setting pwd for another user, delete his password history
		IF (@user_admin = '1' AND @logged_user != @user_login_id)
		BEGIN
			DELETE FROM application_users_password_log WHERE user_login_id = @user_login_id
		END
		--else save this pwd in log			
		ELSE
		BEGIN
			EXEC spa_application_password_log 'i', @user_login_id, NULL, @old_password
		END

		IF dbo.FNADBUser() <> @user_login_id 	
		BEGIN
		/* add logic to send mail via template start */
			DECLARE @template_params VARCHAR(5000)
			DECLARE @user_emal_add VARCHAR(1000)

			SELECT @user_emal_add = user_emal_add 
			FROM application_users 
			WHERE user_login_id = @user_login_id
			
			SET @template_params = ''
			SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<TRM_USER_NAME>', IIF(@cloud_mode = 0, @user_login_id, @user_emal_add))
			SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<TRM_PASSWORD>', @pwd_raw)

			EXEC spa_email_notes @flag = 'i',
							     @send_to = @user_emal_add,
								 @send_status = 'n',
								 @active_flag = 'y',
								 @email_module_type_value_id = 17809,
								 @template_params = @template_params
		/* add logic to send mail via template end */
		END

		IF @@ERROR <> 0
		BEGIN
			EXEC spa_Errorhandler @@ERROR, 'Password Change', 'spa_changedPassword', 'DB Error', 'Failed to change password.'
		END
		ELSE
		BEGIN
			EXEC spa_ErrorHandler 0, 'Password Change', 'spa_changedPassword', 'Success', ' User password changed successfully', ''
		END
	END
END