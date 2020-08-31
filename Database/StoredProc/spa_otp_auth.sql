IF EXISTS (SELECT * FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_otp_auth]') AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_otp_auth]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_otp_auth]
	@flag CHAR,
	@user_login_id VARCHAR(50) = NULL,
	@otp_code VARCHAR(10) = NULL
AS
SET NOCOUNT ON -- NOCOUNT is set ON since returning row count has side effects on exporting table feature
	

DECLARE @description VARCHAR(8000)
DECLARE @user_emal_add VARCHAR(200)
DECLARE @user_name VARCHAR(200)
DECLARE @subject VARCHAR(200)

IF @flag = 's'
BEGIN
BEGIN TRY

	DECLARE @template_params VARCHAR(5000)
	
		SELECT @user_emal_add= au.user_emal_add
			   , @user_name = au.user_f_name
		FROM application_users au WHERE au.user_login_id= @user_login_id

		SELECT @subject = email_subject,
				@description = email_body
		FROM admin_email_configuration WHERE module_type = 17821 AND default_email = 'y'
		
		SET @template_params = ''
		SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<USER_FIRSTNAME>', @user_name)
		SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<OTP_CODE>', @otp_code)

		EXEC spa_email_notes @flag = 'i',
							     @send_to = @user_emal_add,
								 @send_status = 'n',
								 @active_flag = 'y',
								 @email_module_type_value_id = 17821,
								 @template_params = @template_params

		EXEC spa_ErrorHandler 0,
			'Otp send.',
			'spa_otp_auth',
			'Success',
			'Changes have been saved successfully.',
			@user_emal_add
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK

		EXEC spa_ErrorHandler -1,
								'Otp send.',
								'spa_otp_auth',
								'DB Error',
								'Fail to insert email notes.',
								''
	END CATCH
END
