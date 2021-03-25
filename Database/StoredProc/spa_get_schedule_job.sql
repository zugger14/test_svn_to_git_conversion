IF EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[spa_get_schedule_job]') AND [type] IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_get_schedule_job]
GO
	
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE PROC [dbo].[spa_get_schedule_job]
	@flag VARCHAR(1),
	@job_id VARCHAR(2000) = NULL
AS

SET NOCOUNT ON
/*--------------------Debug Section----------------------
DECLARE @flag VARCHAR(1),
        @job_id VARCHAR(1000)

SET @flag = 's'
SET @job_id = 'EB4E85F0-EA15-499D-ACC3-F2CF46D8C945'
---------------------------------------------------------*/

DECLARE @sql_string VARCHAR(MAX)

IF @flag='s'
BEGIN
	IF OBJECT_ID('tempdb..#tmp_job') IS NOT NULL
		DROP TABLE #tmp_job
	
	CREATE TABLE #tmp_job (
		session_id INT,
		job_id VARCHAR(100) COLLATE DATABASE_DEFAULT ,
		job_name SYSNAME,
		run_requested_date DATETIME,
		run_requested_source SYSNAME NULL,
		queued_date DATETIME,
		start_execution_date DATETIME,
		last_executed_step_id INT,
		last_exectued_step_date DATETIME,
		stop_execution_date DATETIME,
		next_scheduled_run_date DATETIME,
		job_history_id INT,
		[message] NVARCHAR(1024) COLLATE DATABASE_DEFAULT ,
		run_status INT,
		operator_id_emailed INT,
		operator_id_netsent INT,
		operator_id_paged INT
	)
  
	INSERT INTO #tmp_job 
	EXEC msdb.dbo.sp_help_jobactivity


	SELECT DISTINCT
		   v.[name] [Name],
		   dbo.FNADateTImeFormat(v.date_created, 1) [date_created],
		   dbo.FNADateTImeFormat(h.next_scheduled_run_date, 1) [next_scheduled_run_date],
		   dbo.FNADateTImeFormat(h.last_exectued_step_date, 1) [last_exectued_step_date],
		   CASE
				WHEN SUSER_SNAME(v.owner_sid) LIKE '% \ %' THEN SUBSTRING(SUSER_SNAME(v.owner_sid), CHARINDEX('\', SUSER_SNAME(v.owner_sid)) + 1, 50)
				ELSE ISNULL(NULLIF((ISNULL(au.user_f_name, '') + ' ' + ISNULL(au.user_m_name, '') + ' ' + ISNULL(au.user_l_name, '')) , '  '), 'System Job')
		   END [owner_sid],
		   CASE h.run_status WHEN 0 THEN 'Failed' 
							 WHEN 1 THEN 'Succeeded'
							 WHEN 2 THEN 'Retry'
							 WHEN 3 THEN 'Canceled'
							 ELSE CASE WHEN h.run_status IS NULL AND h.next_scheduled_run_date > '' + CAST(GETDATE() AS VARCHAR) + '' THEN 'Job in queue'
								  ELSE 'In progress'
						     END
			END [run_status],
			dbo.FNADateTImeFormat(a.date_modified, 1) [date_modified],
			sj.[description] [user_name],
			v.job_id [Job ID]
	FROM msdb.dbo.sysjobs_view v 
	INNER JOIN #tmp_job h ON v.job_id = h.job_id
	INNER JOIN msdb.dbo.sysjobsteps jp ON jp.job_id = v.job_id
	INNER JOIN msdb.dbo.sysjobs sj ON jp.job_id = sj.job_id
	LEFT JOIN application_users au ON au.user_login_id COLLATE SQL_Latin1_General_CP1_CI_AS = sj.[description] COLLATE SQL_Latin1_General_CP1_CI_AS
	LEFT JOIN msdb.dbo.sysjobschedules sjs ON sj.job_id = sjs.job_id
	OUTER APPLY( 
		SELECT TOP 1 ss.schedule_id [schedule_id], ss.date_modified [date_modified]
		FROM msdb.dbo.sysschedules ss
		WHERE ss.schedule_id = sjs.schedule_id
		ORDER BY ss.date_modified DESC
	) a
	WHERE 1 = 1
		AND jp.database_name = DB_NAME()
		AND	((h.next_scheduled_run_date IS NOT NULL OR h.run_status IN (0, 2, 4)) 
			OR (h.next_scheduled_run_date IS NULL AND h.start_execution_date IS NOT NULL AND h.stop_execution_date IS NULL))

	ORDER BY [date_modified]
END
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		SELECT @sql_string = @sql_string + 'EXEC msdb.dbo.sp_delete_job @job_id=''' + item + '''; '
		FROM dbo.SplitCommaSeperatedValues(@job_id)
		
		EXEC (@sql_string)
		EXEC spa_ErrorHandler 0, 'Schedule Job', 'spa_get_schedule_job', 'Success', 'Schedule Job successfully deleted.', ''
	END TRY
	BEGIN CATCH
		DECLARE @e_no INT,
		        @e_msg VARCHAR(1000)
		
		SELECT @e_no = ERROR_NUMBER(),
		       @e_msg = 'Failed to delete: ' + ERROR_MESSAGE()
		
		EXEC spa_ErrorHandler @e_no, 'Schedule Job', 'spa_get_schedule_job', 'DB Error', @e_msg, ''
	END CATCH
END
GO