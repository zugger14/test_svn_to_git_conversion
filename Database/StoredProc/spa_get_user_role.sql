/* Vishwas Khanal
Dated : 09.April.2009
Compliance Integration to TRM
*/

IF OBJECT_ID('[dbo].[spa_get_user_role]','p') IS NOT NULL
drop proc [dbo].[spa_get_user_role]
GO
CREATE proc [dbo].[spa_get_user_role]
         @roleID int=null
         

AS
BEGIN
declare @sqlStmt varchar(2000)

 set @sqlStmt = 'select asr.role_name as ''Role Name'','
  set @sqlStmt = @sqlStmt + '(au.user_l_name + '', '' + au.user_f_name + '' '' + isnull(au.user_m_name, '''')) + CASE WHEN (isnull(aru.user_type, ''o'') = ''p'') THEN ''(Primary)'' WHEN (isnull(aru.user_type, ''o'') = ''s'') THEN ''(Secondary)'' ELSE ''(O
ther)'' END ''User Name'','
 set @sqlStmt = @sqlStmt + 'isnull(au.user_title, '''') ''Title'','
 set @sqlStmt = @sqlStmt +  'isnull(user_off_tel, '''') ''Telephone'','
 set @sqlStmt = @sqlStmt + 'isnull(user_emal_add, '''') ''Email'' '
 
 
 set @sqlStmt = @sqlStmt +  'from application_security_role asr,
                                  application_users au,
                                  application_role_user aru 
                             where asr.role_id = aru.role_id and
                                   aru.user_login_id = au.user_login_id '
           if @roleID is not null 
                set @sqlStmt = @sqlStmt + 'and asr.role_id ='  + cast(@roleID as varchar)
            
EXEC spa_print @sqlStmt
exec(@sqlStmt)

END

