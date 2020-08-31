IF OBJECT_ID(N'spa_adhoc_run_import_job', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_adhoc_run_import_job]
 GO 
CREATE procedure [dbo].[spa_adhoc_run_import_job]
--@job_name_app varchar(100)
as
begin
exec msdb.dbo.sp_start_job @job_name ='Fastracker_Interface_job'
end



