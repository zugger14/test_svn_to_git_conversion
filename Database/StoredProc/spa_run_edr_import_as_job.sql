IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_run_edr_import_as_job]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_run_edr_import_as_job]
GO 


create proc [dbo].[spa_run_edr_import_as_job]
	@user_name varchar(100)

AS
BEGIN


--EXEC spa_run_sp_as_job @job_name, @spa, 'RECTRACKER Import', @user_id
--
--print 'EXEC spa_run_sp_as_job ''' + @job_name +  ''', ''' + @spa + ''', RECTRACKER Import, ''' + @user_id + ''
--
Exec spa_ErrorHandler 0, 'RECTRACKER Import', 
			'spa_run_edr_import_as_job', 'Status', 
			'Data Import Process has been run and will complete shortly.', 
			'Please check/refresh your message board.'


END


