 DECLARE @db VARCHAR(100)
 SET @db = DB_NAME()
 
 SELECT ' IF DATABASE_PRINCIPAL_ID(''' + user_login_id + ''') IS NOT NULL '+ CHAR(10) + ' BEGIN ' + CHAR(10) + 'EXEC sp_droprolemember ''db_owner'', ''' + user_login_id + ''';' + CHAR(10) + '
 EXEC sp_droprolemember ''db_securityadmin'',''' + user_login_id + ''';' + CHAR(10) + '
 IF IS_SRVROLEMEMBER (''securityadmin'', ''' + user_login_id + ''') IS NOT NULL' + CHAR(10) + 'BEGIN' + CHAR(10) +'
 EXEC sp_dropsrvrolemember ''' + user_login_id + ''', ''securityadmin'';' + CHAR(10) + 'END' + CHAR(10) +'
 EXEC sp_addrolemember ''db_farrms'',''' + user_login_id + ''' ' + CHAR(10) + 'END' 
FROM application_users WHERE user_login_id <> 'farrms_admin' 


USE msdb

DECLARE  @sql VARCHAR(8000)


 set @sql = 'SELECT '' IF DATABASE_PRINCIPAL_ID( '''''' + NAME + '''''' ) IS NOT NULL '+ CHAR(10) +
  ' BEGIN ' + CHAR(10) + ' EXEC sp_droprolemember ''''db_owner'''', '''''' + NAME + '''''' ;' + CHAR(10) + '
 EXEC sp_droprolemember ''''db_securityadmin'''', '''''' + NAME + '''''';' + CHAR(10) + '
 EXEC sp_droprolemember ''''SQLAgentOperatorRole'''', '''''' + NAME + '''''';' + CHAR(10) + '
 EXEC sp_droprolemember ''''SQLAgentReaderRole'''', '''''' + NAME + '''''';' + CHAR(10) + '
 EXEC sp_droprolemember ''''SQLAgentUserRole'''', '''''' + NAME + '''''';' + CHAR(10) + '
 EXEC sp_addrolemember ''''db_farrms'''', '''''' + NAME + '''''';' + CHAR(10) + '
 END''
FROM msdb.dbo.sysusers ms inner join ' + @db + '.dbo.application_users au ON au.user_login_id = ms.name
WHERE islogin = 1 AND hasdbaccess = 1 AND NAME <> ''farrms_admin''' 

PRINT @sql
EXEC(@sql)


USE adiha_process


DECLARE  @sql2 VARCHAR(8000)


 set @sql2 = 'SELECT '' IF DATABASE_PRINCIPAL_ID('''''' + NAME + '''''') IS NOT NULL '+ CHAR(10) + ' BEGIN ' + CHAR(10) +'
EXEC sp_droprolemember ''''db_owner'''', '''''' + name + '''''';' + CHAR(10) +'
EXEC sp_droprolemember ''''db_securityadmin'''','''''' + name + '''''';' + CHAR(10) +'
EXEC sp_droprolemember ''''db_datareader'''', '''''' + name + '''''';' + CHAR(10) +'
EXEC sp_droprolemember ''''db_datawriter'''', '''''' + name + '''''';' + CHAR(10) +'
EXEC sp_droprolemember ''''db_ddladmin'''', '''''' + name + '''''';' + CHAR(10) +'
EXEC sp_addrolemember ''''db_farrms'''','''''' + name + ''''''END''  
FROM adiha_process.dbo.sysusers ms inner join ' + @db + '.dbo.application_users au ON au.user_login_id = ms.name
WHERE islogin = 1 AND hasdbaccess = 1 AND NAME <> ''farrms_admin'''


PRINT @sql2
EXEC(@sql2)