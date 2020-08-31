IF OBJECT_ID(N'spa_GetAccessRights', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_GetAccessRights]
GO 

CREATE PROCEDURE [dbo].[spa_GetAccessRights]
@func_id AS INT,
@Login_id AS VARCHAR(30)
AS
BEGIN
	SELECT c.*
	FROM   application_functions a,
	       application_functions b,
	       application_functional_users c
	WHERE  a.func_ref_id = b.function_id
	       AND b.function_id = @func_id
	       AND a.function_id = c.function_id
	       AND c.login_id = @login_id

	IF @@error <> 0
	    EXEC spa_ErrorHandler @@error,
	         'User Security Mgmt',
	         'spa_GetAccessRight',
	         'DB Error',
	         'Failed to select the user access rights data.',
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'User Securiry Mgmt',
	         'spa_GetAccessRight',
	         'Success',
	         'User Access Right Data inserted sucessfully.',
	         ''

			 
END