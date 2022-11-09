IF OBJECT_ID(N'[dbo].[spa_import_web_service]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_import_web_service]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
/**  
	Different operations using table import_web_service

	Parameters
	@flag : Flag
		'w' - For import web service
	@rules_id : ID of import rule
	@ws_name : Web service Name,
	@auth_token : Authentication token for web service
	@password : Password of webservice
	@password_updated_date : Password update date

*/

CREATE PROCEDURE [dbo].[spa_import_web_service]
    @flag CHAR(1),
	@rules_id INT = NULL,
	@ws_name NVARCHAR(50) = NULL,
	@auth_token NVARCHAR(1000) = NULL,
	@password NVARCHAR(100) = NULL,
	@password_updated_date DATETIME = NULL
AS
SET NOCOUNT ON
IF @flag = 'w'
BEGIN
	SELECT web_service_url
		, [user_name]		
		, dbo.FNADecrypt([password])[password]
		, [auth_token]
		, [request_body]
		, [request_params]
		, [auth_url]
		, [client_id]
		, [client_secret]
		, [certificate_path]
		, [password_updated_date]
		, [api_key]
	FROM ixp_import_data_source iids
	INNER JOIN import_web_service iws
		ON iids.clr_function_id = iws.clr_function_id
	WHERE rules_id = @rules_id
END
ELSE IF @flag = 'a'
BEGIN
	UPDATE import_web_service 
	SET auth_token = ISNULL(@auth_token, auth_token),
		[password] = ISNULL(dbo.FNAEncrypt(@password), [password]), 
		password_updated_date = ISNULL(@password_updated_date, password_updated_date)	
	WHERE ws_name = @ws_name
END
GO
