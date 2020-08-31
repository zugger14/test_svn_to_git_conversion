IF OBJECT_ID('spa_mobile_notification') IS NOT NULL
	DROP PROC spa_mobile_notification
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_mobile_notification]
(
    @push_xml NVARCHAR(MAX),
    @debug_mode NCHAR(1) = 'n',
    @result NVARCHAR(MAX) OUTPUT
)
AS
	BEGIN
		DECLARE @push_php_url VARCHAR (1024)
		SELECT @push_php_url = SUBSTRING(cs.file_attachment_path,0,CHARINDEX('TRM/',cs.file_attachment_path,0)) + 'api/notifications/push_notification.php' FROM connection_string cs
										
		DECLARE @output_result VARCHAR (1024), @app_user_email_address VARCHAR(255)
		
		SELECT @app_user_email_address = user_emal_add FROM application_users WHERE user_login_id = dbo.FNADBUser()
		--## Email address is appended in URL for database connection in cloud mode from this URL
		SET @push_xml = 'push_xml=' + @push_xml + '&app_user_name=' + @app_user_email_address
		EXEC spa_push_notification @push_php_url, @push_xml, @debug_mode, @output_result OUTPUT
		SET @result = @output_result
	END
GO

