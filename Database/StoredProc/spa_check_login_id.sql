IF OBJECT_ID('[dbo].[spa_check_login_id]', 'p') IS NOT NULL
DROP PROCEDURE [dbo].[spa_check_login_id]
GO
CREATE PROCEDURE [dbo].[spa_check_login_id]
@login_id VARCHAR(50)
AS
DECLARE @message VARCHAR(MAX)
	if exists(
		SELECT * 
		FROM application_users 
		WHERE user_login_id = @login_id
	)
		Exec spa_ErrorHandler -1, 'MaintainUsers', 'spa_check_login_id', 'DB Error', 'User Login Id already exists.', ''	
	else
		Exec spa_ErrorHandler 0, 'MaintainUsers', 'spa_check_login_id', 'DB Success', 'Success', ''	