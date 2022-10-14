IF OBJECT_ID(N'spa_export_web_service', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_export_web_service]
GO 
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: ashakya@pioneersolutionsglobal.com
-- Create date: 2017-08-23
 
-- Params:
-- @flag CHAR(1)
-- @object t VARCHAR(100) - Web service Object
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_export_web_service]
	@flag CHAR(1),
	@id INT = NULL,
	@handler_class_name VARCHAR(100) = NULL
AS
SET NOCOUNT ON

IF @flag = 's'
BEGIN 
	SELECT web_service_url,
			auth_token, 
			handler_class_name, 
			[user_name], 
			request_param,
			auth_url,
			dbo.FNADecrypt([password]) [password],
			ws_name,
			auth_key,
			token_updated_date 
	FROM export_web_service 
	WHERE id = @id
END
ELSE IF @flag = 'c' 
BEGIN
	SELECT id, ws_name FROM export_web_service
END
GO