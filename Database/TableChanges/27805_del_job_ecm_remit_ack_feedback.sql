DECLARE @db_name NVARCHAR(100)
DECLARE @job_name NVARCHAR(250)
SET @db_name = DB_NAME()

SET @job_name = @db_name + N' - Import - ECM Remit ACK Feedback Capture'

IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE NAME = @job_name)
	EXEC msdb.dbo.sp_delete_job @job_name = @job_name, @delete_unused_schedule = 1