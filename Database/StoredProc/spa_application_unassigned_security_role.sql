IF OBJECT_ID(N'spa_application_unassigned_security_role', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_application_unassigned_security_role]
GO
--This procedure returns unassigned security roles for a given user.

CREATE PROC [dbo].[spa_application_unassigned_security_role]
			@user_login_id varchar(50)=NULL
AS
--select role_id from application_role_user where user_login_id = 'nshrestha' 
SELECT 
	asr.role_id AS [Role Id]
	, asr.role_name AS [Role Name]
	, asr.role_description AS [Role Description]
	, asr.role_type_value_id
	, asr.create_user
	, asr.create_ts
	, asr.update_user
	, asr.update_ts
FROM application_security_role asr
LEFT JOIN application_role_user aru 
ON aru.role_id = asr.role_id
AND aru.user_login_id = @user_login_id
WHERE aru.role_id IS NULL
ORDER BY role_name ASC

	
IF @@ERROR <> 0
	Exec spa_ErrorHandler @@ERROR, "application_security_role", 
		"spa_application_security_role", "DB Error", 
		"Select of all application security Roles failed.", ''




