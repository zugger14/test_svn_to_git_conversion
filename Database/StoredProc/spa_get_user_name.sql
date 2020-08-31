IF OBJECT_ID(N'[dbo].[spa_get_user_name]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_user_name]
GO 
--drop proc spa_get_user_name
--exec spa_get_user_name 'ubaral'

-----this procedure returns User Name
--EXEC spa_get_user_name
CREATE PROCEDURE [dbo].[spa_get_user_name]
	@user_login_id varchar(100) = NULL,
	@flag CHAR(1) = NULL -- flag 's' added to use application_users_id instead of user_login_id

 AS
Declare @sqlstmt varchar(300)

IF @flag = 's'
BEGIN
	set @sqlstmt='select application_users_id, (user_l_name + '', '' + user_f_name + '' '' + isnull(user_m_name, '''') + '' ('' + user_login_id + '')'') As user_name 
	  from application_users'	
END
ELSE 
BEGIN
	set @sqlstmt='select user_login_id, (user_l_name + '', '' + user_f_name + '' '' + isnull(user_m_name, '''') + '' ('' + user_login_id + '')'') As user_name 
	  from application_users'
END

if @user_login_id is not NULL
begin
	set @sqlstmt = @sqlstmt +' where user_login_id='+''''+@user_login_id+''''

end
     set @sqlstmt = @sqlstmt +' order by user_name'

exec(@sqlstmt)




