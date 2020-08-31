/****** Object:  StoredProcedure [dbo].[spa_job_queue]    Script Date: 04/20/2009 17:55:41 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_job_queue]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_job_queue]
/****** Object:  StoredProcedure [dbo].[spa_job_queue]    Script Date: 04/20/2009 17:55:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_job_queue] 
				 @run_job_name varchar(100)=NULL
				,@source_system_name varchar(100)=NULL
				,@flag char(1)=NULL -- To determine the request for IMPORT Source System
AS
DECLARE @job_to_execute varchar(100)
SET @job_to_execute=NULL

if @source_system_name IS NOT NULL 
BEGIN
	
--	SELECT TOP (1) @job_to_execute = [name] FROM msdb.dbo.sysjobs_view WHERE [enabled]=1 AND [name]<> @run_job_name AND [name] LIKE  'importdata%' ORDER BY date_created ASC
	SELECT TOP (1) @job_to_execute=v.[name] FROM dbo.farrms_sysjobactivity a INNER JOIN msdb.dbo.sysjobs_view v ON a.job_id=v.job_id 
			WHERE v.[enabled]=1 and v.[name]<> @run_job_name AND v.[name] LIKE 'importdata%' AND a.stop_execution_date IS NULL
			AND a.schedule_id IS NULL
			ORDER BY date_created ASC

	if @job_to_execute IS NOT NULL
		EXEC msdb.dbo.sp_start_job @job_name = @job_to_execute
END
--SELECT (date_created), [name] FROM msdb.dbo.sysjobs_view  WHERE [name]<> 'Cleanup expired jobs' AND [name] LIKE  'clean%' GROUP BY [name], date_modified ORDER BY date_modified ASC

