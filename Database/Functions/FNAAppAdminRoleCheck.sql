IF OBJECT_ID(N'[dbo].[FNAAppAdminRoleCheck]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAAppAdminRoleCheck]
    
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rtuladhar@pioneersolutionsglobal.com
-- Create date: 2012-06-18
-- Description: checks if user has admin role or not
--SELECT [dbo].FNAAppAdminRoleCheck('r887s055')
--returns 0(not app admin) 1(app admin)
-- ===========================================================================================================


CREATE FUNCTION [dbo].[FNAAppAdminRoleCheck](
	@user_name VARCHAR(MAX)
)
RETURNS INT
AS
BEGIN
	DECLARE @FNAAppAdminID INT

	IF @user_name = dbo.FNAAppAdminID() 
	BEGIN
		SET @FNAAppAdminID = 1; 
	END 
	ELSE 
	BEGIN
		SELECT @FNAAppAdminID = CASE WHEN asr.role_type_value_id = 7 THEN 1 ELSE 0 END 
		FROM  application_users au
			INNER JOIN application_role_user aru ON au.user_login_id = aru.user_login_id
			INNER JOIN application_security_role asr ON asr.role_id = aru.role_id
			INNER JOIN static_data_value sdv ON sdv.value_id = asr.role_type_value_id 
				AND sdv.value_id = 7
		WHERE au.user_login_id = @user_name

		SET @FNAAppAdminID = ISNULL(@FNAAppAdminID, 0)
	END
		
	RETURN(@FNAAppAdminID)
END





