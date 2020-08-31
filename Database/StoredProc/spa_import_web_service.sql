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

*/

CREATE PROCEDURE [dbo].[spa_import_web_service]
    @flag CHAR(1),
	@rules_id INT = NULL
    
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
	FROM ixp_import_data_source iids
	INNER JOIN import_web_service iws
		ON iids.clr_function_id = iws.clr_function_id
	WHERE rules_id = @rules_id
END
GO
