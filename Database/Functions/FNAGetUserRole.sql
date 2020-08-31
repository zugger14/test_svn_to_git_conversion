IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[FNAGetUserRole]') 
			AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
   DROP FUNCTION [dbo].[FNAGetUserRole]
    
GO
    
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rtuladhar@pioneersolutionsglobal.com
-- Create date: 2012-06-18
-- Description: checks if user has admin role or not
--SELECT * FROM dbo.FNAGetUserRole('r887055')
--returns list of roles assigned to user
-- ===========================================================================================================

CREATE FUNCTION [dbo].[FNAGetUserRole](
	@user_name VARCHAR(500)
)
RETURNS TABLE 
AS
	RETURN
	SELECT aru.role_id 
	FROM  application_users au
	INNER JOIN application_role_user aru ON au.user_login_id = aru.user_login_id
	INNER JOIN application_security_role asr ON asr.role_id = aru.role_id
	INNER JOIN static_data_value sdv ON sdv.value_id = asr.role_type_value_id 
	WHERE au.user_login_id = @user_name
	
