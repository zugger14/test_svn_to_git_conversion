PRINT 'Grant role to existing users for SSIS execution'

Declare @user_login_id VARCHAR(100)

dECLARE cur_files CURSOR FOR

SELECT user_login_id  FROM dbo.application_users

OPEN cur_files

--USE msdb

FETCH NEXT FROM cur_files INTO @user_login_id

WHILE @@FETCH_STATUS = 0

BEGIN

      IF USER_ID(@user_login_id) IS NOT NULL

      begin

            PRINT 'Login_id:'+@user_login_id

            exec msdb.dbo.sp_addrolemember 'SQLAgentOperatorRole', @user_login_id

            EXEC msdb.dbo.sp_addrolemember 'SSIS_Job_Farrms_Role',  @user_login_id
            

      END

      FETCH NEXT FROM cur_files INTO @user_login_id

END

CLOSE cur_files

DEALLOCATE cur_files