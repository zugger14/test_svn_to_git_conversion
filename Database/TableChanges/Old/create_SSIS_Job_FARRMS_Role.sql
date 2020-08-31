USE msdb
GO

IF  NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'SSIS_Job_Farrms_Role' AND type = 'R')
	CREATE ROLE [SSIS_Job_Farrms_Role] AUTHORIZATION [dbo]

GO