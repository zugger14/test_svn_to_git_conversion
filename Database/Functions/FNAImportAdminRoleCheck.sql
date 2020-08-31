IF OBJECT_ID(N'[dbo].[FNAImportAdminRoleCheck]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAImportAdminRoleCheck]
    
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rkhatiwada@pioneersolutionsglobal.com
-- Create date: 2018-02-01
-- Description: checks if user has admin role or not
--SELECT [dbo].FNAImportAdminRoleCheck('r887s055')
--returns 0(not import admin) 1(import admin)
-- ===========================================================================================================


CREATE FUNCTION [dbo].[FNAImportAdminRoleCheck](
	@user_name VARCHAR(50)
)
RETURNS INT
AS
BEGIN
	DECLARE @import_admin INT;

	IF @user_name = dbo.FNAAppAdminID() 
	BEGIN
		SET @import_admin = 1;	
	END
	ELSE 
	BEGIN	
		SELECT @import_admin = CASE WHEN asr.role_type_value_id = 2 THEN 1 
									ELSE 0 
							   END 
		FROM  application_users au
		INNER JOIN application_role_user aru ON au.user_login_id = aru.user_login_id
		INNER JOIN application_security_role asr ON asr.role_id = aru.role_id
		WHERE asr.role_type_value_id = 2		--static data value for import integration admin group
			AND au.user_login_id = @user_name
	END
	
	RETURN(ISNULL(@import_admin, 0))
END