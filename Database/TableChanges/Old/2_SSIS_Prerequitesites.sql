/*
* Creates farrms_sysjobactivity in main db, which will be used for job queuing.
*/

PRINT 'Create View'
GO
	
IF  EXISTS (SELECT * FROM sys.views WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[farrms_sysjobactivity]'))
DROP VIEW [dbo].[farrms_sysjobactivity]
GO
CREATE VIEW [dbo].[farrms_sysjobactivity]
AS
SELECT a.*, b.schedule_id 
FROM msdb.dbo.sysjobactivity a
LEFT JOIN msdb.dbo.sysjobschedules b ON a.job_id = b.job_id
GO

