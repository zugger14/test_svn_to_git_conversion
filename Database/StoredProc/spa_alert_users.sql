IF OBJECT_ID(N'[dbo].[spa_alert_users]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_alert_users]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2012-11-03
-- Description: CRUD operations for table alert_users
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_alert_users]
    @flag CHAR(1),
    @alert_user_id INT = NULL,
    @alert_sql_id INT = NULL,
    @role_user CHAR(1) = NULL,
    @role_id INT = NULL,
	@user_login_id VARCHAR(100) = NULL
AS
DECLARE @DESC VARCHAR(500)
IF @flag = 'i'
BEGIN
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM alert_users aw WHERE aw.alert_sql_id = @alert_sql_id AND (aw.role_id = @role_id OR aw.user_login_id = @user_login_id))
		BEGIN
			EXEC spa_ErrorHandler -1,
		     'alert_users',
		     'spa_alert_users',
		     'Error',
		     'User or Roles already exists for selected SQL.',
		     ''
		    RETURN
		END
		INSERT INTO alert_users (alert_sql_id, role_user, role_id, user_login_id)
		SELECT @alert_sql_id, @role_user, @role_id, @user_login_id
		
		EXEC spa_ErrorHandler 0,
		     'alert_users',
		     'spa_alert_users',
		     'Success',
		     'Successfully inserted data.',
		     ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		EXEC spa_ErrorHandler @@ERROR,
		     'alert_users',
		     'spa_alert_users',
		     'Error',
		     @DESC,
		     ''
	END CATCH
END
ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
		UPDATE alert_users
		SET    role_user = @role_user,
		       role_id = @role_id,
		       user_login_id = @user_login_id
		WHERE  alert_users_id = @alert_user_id
		
		EXEC spa_ErrorHandler 0,
		     'alert_users',
		     'spa_alert_users',
		     'Success',
		     'Successfully updated data.',
		     ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC = 'Fail to update Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		EXEC spa_ErrorHandler @@ERROR,
		     'alert_users',
		     'spa_alert_users',
		     'Error',
		     @DESC,
		     ''
	END CATCH
END
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		DELETE FROM alert_users WHERE alert_users_id = @alert_user_id		
		EXEC spa_ErrorHandler 0,
		     'alert_users',
		     'spa_alert_users',
		     'Success',
		     'Successfully deleted data.',
		     ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC = 'Fail to delete Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		EXEC spa_ErrorHandler @@ERROR,
		     'alert_users',
		     'spa_alert_users',
		     'Error',
		     @DESC,
		     ''
	END CATCH	
END
ELSE IF @flag = 's'
BEGIN
	SELECT au.alert_users_id [Users ID],
	       as1.alert_sql_name [Rule Name],
	       CASE WHEN au.role_user = 'r' THEN 'Role' ELSE 'User' END [Role/User],
	       asr.role_name [Role],
	       au2.user_f_name + ' ' + ISNULL(au2.user_m_name, '') + ' ' + au2.user_l_name [User]
	FROM   alert_users au
	LEFT JOIN application_security_role asr ON asr.role_id = au.role_id
	LEFT JOIN application_users au2 ON au2.user_login_id = au.user_login_id
	LEFT JOIN alert_sql as1 ON as1.alert_sql_id = au.alert_sql_id
	WHERE au.alert_sql_id = @alert_sql_id
END
ELSE IF @flag = 'a'
BEGIN
	SELECT au.alert_users_id,
	       au.alert_sql_id,
	       au.role_user,
	       au.role_id,
	       au.user_login_id
	FROM   alert_users au
	WHERE  au.alert_users_id = @alert_user_id
END