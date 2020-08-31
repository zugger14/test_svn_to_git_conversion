IF OBJECT_ID(N'spa_get_user_admin_name', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_get_user_admin_name]
GO

CREATE PROC [dbo].[spa_get_user_admin_name]
	@flag CHAR(1),
	@value_id INT,
	@user VARCHAR(100),
	@description VARCHAR(100)
AS
IF @flag = 's'
BEGIN
	SELECT au.user_login_id
			, (au.user_l_name + ', ' + au.user_f_name + ' ' + ISNULL(au.user_m_name, '') + ' (' + au.user_login_id + ')') AS [User Name]
	FROM application_users au
	ORDER BY au.user_l_name
END

ELSE IF @flag = 'a'
BEGIN
	SELECT value_id, type_id, code, description FROM static_data_value WHERE value_id = @value_id
END

ELSE IF @flag = 'u'
BEGIN
	UPDATE static_data_value
     SET    code = @user,
			description = @description
     WHERE  value_id = @value_id
     
     IF @@Error <> 0
         EXEC spa_ErrorHandler @@Error,
              'System User',
              'spa_get_user_admin_name',
              'DB Error',
              'Failed to update system user value.',
              ''
     ELSE
         EXEC spa_ErrorHandler 0,
              'System User',
              'spa_get_user_admin_name',
              'Success',
              'Sustem user updated.',
              ''
END