IF OBJECT_ID('[spa_connection_string]') IS NOT NULL
	DROP  PROCEDURE [dbo].[spa_connection_string]
GO
/**
	Connection string table related get operations
	Parameters
	@flag		: 's' get all information of connection string
				  'r' get report server related information 
				  'v' get validity of system defined passwords
				  't' get API token expiry days
	@password	: system defined password string value
*/
CREATE PROC [dbo].[spa_connection_string]
@flag CHAR(1),
@password VARCHAR(50) = NULL

AS

IF @flag = 's'
BEGIN
	SELECT *
	FROM connection_string cs
END
ELSE IF @flag = 'r'
BEGIN
	SELECT cs.db_DatabaseName, cs.db_Servername, cs.db_UserName, cs.is_default
	, cs.document_path, cs.email_profile, cs.file_attachment_path, cs.smtp_server, cs.sql_proxy_account, cs.import_path, cs.php_path
	, cs.report_server_url, cs.report_server_domain, cs.report_server_user_name, dbo.FNADecrypt(cs.report_server_password) [report_server_password], cs.report_server_datasource_name, cs.report_server_target_folder, cs.report_folder
	
	FROM connection_string cs
END
ELSE IF @flag = 'v' 
BEGIN
	IF EXISTS (SELECT 1 FROM connection_string WHERE system_defined_password = @password)
	BEGIN
		SELECT '1' [is_valid] 
	END
	ELSE
	BEGIN
		SELECT '0' [is_valid] 
	END
END
ELSE IF @flag = 't'
BEGIN
	SELECT ISNULL(api_token_expiry_days,60) [tokenExpiryDays] FROM connection_string
END