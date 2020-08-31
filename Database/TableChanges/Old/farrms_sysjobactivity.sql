IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[farrms_sysjobactivity]'))
DROP VIEW [dbo].[farrms_sysjobactivity]
GO
/****** Object:  View [dbo].[farrms_sysjobactivity]    Script Date: 2/15/2016 4:44:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[farrms_sysjobactivity]
AS
SELECT a.*, b.schedule_id 
FROM msdb.dbo.sysjobactivity a
LEFT JOIN msdb.dbo.sysjobschedules b ON a.job_id = b.job_id

GO
