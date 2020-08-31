/*
* Creates SSIS_Job_Farrms_Role in msdb. This role provides 2 purposes as follows:
*	1. This role will be mapped to proxy TRMTracker_proxy which will be mapped to a credential. Credential is defined typically for a Windows user
*	   which has read/write permission in folders (may be network path) where SSIS package needs read/write access. So assigning any FARRMS user
*	   to this role will gain privilege to read/write folders, when they try to execute any SSIS package.
*	2. Job Queue system requires accessing msdb objects (sysjobactivity, sysjobschedules), which is not implicitly accessible. But any view created
*	   under msdb has implicit access to them, but creating view in msdb has serious security concerns. Previously view farrms_sysjobactivity was
*	   created in this msdb so that those objects are accessible, but then this view has been moved to main db. Explicit permission is granted on those 
*	   objects for this SSIS_Job_Farrms_Role, so that any user under it will have access to those objects (and job queue functionality). Under this context
*	   the view farrms_sysjobactivity serves nothing than providing columns from those objects and doesn't serve as a way to access those msdb objects as
*	   the explicit privilege is already granted via SSIS_Job_Farrms_Role.
*	   
* Prerequisite: Proxy and Credentials are created first.
* 
*/

USE [msdb]
GO

PRINT 'Create role'
GO

IF  NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'SSIS_Job_Farrms_Role' AND type = 'R')
	CREATE ROLE [SSIS_Job_Farrms_Role] AUTHORIZATION [dbo]
GO

GRANT SELECT ON [msdb].[dbo].[sysjobactivity] TO SSIS_Job_Farrms_Role
GRANT SELECT ON [msdb].[dbo].[sysjobschedules] TO SSIS_Job_Farrms_Role
GO

PRINT 'Grant role n proxy'
GO
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name = 'TRMTracker_proxy', @msdb_role = 'SSIS_Job_Farrms_Role'
GO