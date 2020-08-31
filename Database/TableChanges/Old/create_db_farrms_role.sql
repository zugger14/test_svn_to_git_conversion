/*
* Essent uses db_farrms role 
*/
IF DATABASE_PRINCIPAL_ID('db_farrms') IS NULL
BEGIN 
	CREATE ROLE db_farrms
END 
GRANT SELECT TO db_farrms
GRANT INSERT TO db_farrms
GRANT UPDATE TO db_farrms
GRANT DELETE TO db_farrms
GRANT EXECUTE TO db_farrms

--required to allow user to create new user
EXEC sp_addrolemember 'db_securityadmin','db_farrms'
EXEC sp_addrolemember 'db_accessadmin','db_farrms'

USE msdb
--IF DATABASE_PRINCIPAL_ID('SQLAgentOperatorRoleNonSystem') IS NULL
--BEGIN 
--	CREATE ROLE SQLAgentOperatorRoleNonSystem
--END 
--EXEC sp_addrolemember 'SQLAgentReaderRole','SQLAgentOperatorRoleNonSystem'

IF DATABASE_PRINCIPAL_ID('db_farrms') IS NULL
BEGIN 
	CREATE ROLE db_farrms
END

--required to allow create/edit/run SQL Agent Job
EXEC sp_addrolemember 'SQLAgentReaderRole','db_farrms'

--required to run SSIS package
EXEC sp_addrolemember 'SSIS_Job_Farrms_Role','db_farrms'

--required to allow user to create new user
EXEC sp_addrolemember 'db_securityadmin','db_farrms'
EXEC sp_addrolemember 'db_accessadmin','db_farrms'

--required for job queue and View Scheduled Job feature
GRANT SELECT ON [msdb].[dbo].[sysjobactivity] TO db_farrms
GRANT SELECT ON [msdb].[dbo].[sysjobschedules] TO db_farrms
GRANT SELECT ON [msdb].[dbo].[sysschedules] TO db_farrms

USE adiha_process
GO

IF DATABASE_PRINCIPAL_ID('db_farrms') IS NULL
BEGIN 
	CREATE ROLE db_farrms
END 
EXEC sp_addrolemember 'db_datareader','db_farrms'
EXEC sp_addrolemember 'db_datawriter','db_farrms'
EXEC sp_addrolemember 'db_ddladmin','db_farrms'

--required to allow user to create new user
EXEC sp_addrolemember 'db_securityadmin','db_farrms'
EXEC sp_addrolemember 'db_accessadmin','db_farrms'


USE master
GO
IF DATABASE_PRINCIPAL_ID('db_farrms') IS NULL
BEGIN 
	CREATE ROLE db_farrms
END 

GRANT EXECUTE ON xp_cmdshell TO db_farrms

--required to allow user to create new user
EXEC sp_addrolemember 'db_securityadmin','db_farrms'
EXEC sp_addrolemember 'db_accessadmin','db_farrms'

--required for OLE object (OLE Automation Stored Procedures, sp_OAMethod, sp_OACreate, sp_OAGetErrorInfo)
USE master
GO
IF DATABASE_PRINCIPAL_ID('db_farrms') IS NULL
BEGIN 
	CREATE ROLE db_farrms
END 

GO
GRANT EXECUTE on sp_OACreate TO db_farrms
GO
GRANT EXECUTE on sp_OAMethod TO db_farrms
GO
GRANT EXECUTE on sp_OADestroy TO db_farrms
GO
GRANT EXECUTE on sp_OAGetErrorInfo TO db_farrms