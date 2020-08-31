IF OBJECT_ID('[dbo].[spa_application_db_users]', 'p') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_application_db_users]
GO 
CREATE PROC [dbo].[spa_application_db_users]
	@flag CHAR(1),
	@user_login_id VARCHAR(50),
	@user_db_pwd VARCHAR(50) = NULL,
	@return_success_msg BIT = 1
AS
DECLARE	@ERROR INT,
		@dbname VARCHAR(50), 
		@clientName VARCHAR(100), 
		@sqlCommand VARCHAR(MAX), 
		@login_permissions INT 

SET @dbname = DB_NAME()

SELECT @login_permissions = HAS_PERMS_BY_NAME(NULL, NULL, 'ALTER ANY LOGIN')

IF @flag = 'i' AND @user_login_id IS NOT NULL 
BEGIN
	IF NOT EXISTS(SELECT 1 FROM master.dbo.syslogins WHERE [name] = @user_login_id)
	BEGIN
		EXEC ('CREATE LOGIN [' + @user_login_id + '] 
				WITH PASSWORD = ''' + @user_db_pwd + ''',
				DEFAULT_DATABASE = ' + @dbname + ',
				CHECK_POLICY = OFF;'
			)
	END
				
	EXEC sp_addsrvrolemember @user_login_id, 'bulkadmin'
	EXEC sp_addsrvrolemember @user_login_id, 'securityadmin'
		
	EXEC('
		IF NOT EXISTS (SELECT 1 FROM sys.sysusers WHERE name = ''' + @user_login_id + ''')
		BEGIN
			CREATE USER [' + @user_login_id + '] 
			WITH DEFAULT_SCHEMA = dbo
			EXEC sp_addrolemember ''db_farrms'', ''' + @user_login_id + '''
		END'
		)
	
	-- assign roles for Database Adiha_Process
	EXEC ('USE adiha_process;
		IF NOT EXISTS (SELECT 1 FROM sys.sysusers WHERE name = ''' + @user_login_id + ''')
		BEGIN
			CREATE USER [' + @user_login_id + '] 
			WITH DEFAULT_SCHEMA = dbo
			EXEC sp_addrolemember ''db_farrms'', ''' + @user_login_id + '''
		END'
		)
	  
	-- assign role needed to run job  
	SELECT @sqlCommand = 'USE msdb;
	IF NOT EXISTS (SELECT 1 FROM sys.sysusers WHERE name = ''' + @user_login_id + ''')
	BEGIN
		CREATE USER [' + @user_login_id + '] 
		WITH DEFAULT_SCHEMA = dbo 
		EXEC sp_addrolemember ''db_farrms'', ''' + @user_login_id + '''
	END'		
			 
	EXEC(@sqlCommand)
	
	IF (@return_success_msg = 1)
		EXEC spa_ErrorHandler 0, 
						'Application DB User', 
						'spa_application_DB_User', 
						'Success', 
						'Changes have been saved successfully.', 
						''		
END


ELSE IF @flag = 'd' AND @user_login_id IS NOT NULL
BEGIN
	DECLARE @deleted_user_login_id VARCHAR(50)
	SET @deleted_user_login_id = QUOTENAME(@user_login_id)


	EXEC (' USE msdb
			IF SCHEMA_ID(''' + @user_login_id + ''') IS NOT NULL
			BEGIN
				DROP SCHEMA ' + @deleted_user_login_id + '  
			END
			IF USER_ID(''' + @user_login_id + ''') IS NOT NULL
			BEGIN
				DROP USER ' + @deleted_user_login_id + '  
			END'			
		)

	EXEC (' USE adiha_process
			IF SCHEMA_ID(''' + @user_login_id + ''') IS NOT NULL
			BEGIN
				DROP SCHEMA ' + @deleted_user_login_id + '  
			END
			IF USER_ID(''' + @user_login_id + ''') IS NOT NULL
			BEGIN
				DROP USER ' + @deleted_user_login_id + '  
			END
			'		
			)

	EXEC (' USE MASTER
			IF SCHEMA_ID(''' + @user_login_id + ''') IS NOT NULL
			BEGIN
				DROP SCHEMA ' + @deleted_user_login_id + '  
			END
			IF USER_ID(''' + @user_login_id + ''') IS NOT NULL
			BEGIN
				DROP USER ' + @deleted_user_login_id + '  
			END
			'		
	)

	EXEC ('	IF SCHEMA_ID(''' + @user_login_id + ''') IS NOT NULL
			BEGIN
				DROP SCHEMA ' + @deleted_user_login_id + '  
			END'
			)

	EXEC ('	IF USER_ID(''' + @user_login_id + ''') IS NOT NULL
			BEGIN
				DROP USER ' + @deleted_user_login_id + '  
			END'
			)

	EXEC ('	IF EXISTS(SELECT 1 FROM master.dbo.syslogins WHERE [loginname]=''' + @user_login_id + ''')
			BEGIN
				DROP LOGIN ' + @deleted_user_login_id + '  
			END'
			)

END

