IF OBJECT_ID(N'[dbo].[FNASecurityAdminRoleCheck]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNASecurityAdminRoleCheck]
    
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rtuladhar@pioneersolutionsglobal.com
-- Create date: 2013-09-23
-- Description: checks if user has admin role or not
--SELECT [dbo].FNASecurityAdminRoleCheck('r887s055')
--returns 0(not app admin) 1(app admin)
-- ===========================================================================================================


CREATE FUNCTION [dbo].[FNASecurityAdminRoleCheck](
	@user_name VARCHAR(MAX)
)
RETURNS INT
AS
BEGIN
	DECLARE @security_admin INT

	IF @user_name = dbo.FNAAppAdminID() 
	BEGIN
		SET @security_admin = 1;	
	END
	ELSE 
	BEGIN	
		SELECT @security_admin = CASE WHEN asr.role_type_value_id = 1 THEN 1 ELSE 0 END 
		FROM  application_users au
			INNER JOIN application_role_user aru ON au.user_login_id = aru.user_login_id
			INNER JOIN application_security_role asr ON asr.role_id = aru.role_id
			INNER JOIN static_data_value sdv ON sdv.value_id = asr.role_type_value_id 
				AND sdv.value_id = 1 --static data value for Security admin group
		WHERE au.user_login_id = @user_name --dbo.FNADBUser()
	
		SET @security_admin = ISNULL(@security_admin, 0)
	END
	
	RETURN(@security_admin)
END





