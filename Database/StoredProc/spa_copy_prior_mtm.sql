IF OBJECT_ID(N'spa_copy_prior_mtm', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_copy_prior_mtm]
 GO 
--spa_copy_prior_mtm 'c','2008-04-30','2007-12-28'
CREATE proc [dbo].[spa_copy_prior_mtm]
@flag char(1),
@as_of_date_copy varchar(20),
@as_of_date_from varchar(20)
as

DECLARE @spa varchar(500)
DECLARE @job_name varchar(100)

DECLARE @process_id varchar(50),@user_login_id varchar(50)

SET @process_id = REPLACE(newid(),'-','_')
set @user_login_id=dbo.FNADBUser()
SET @job_name = 'prior_cpy_mtm_'+ @process_id

SET @spa = 'spa_copy_prior_mtm_job '''+@flag +''',
	''' + @as_of_date_copy  +''',
	 ''' +@as_of_date_from+''','''+@process_id+''''

exec spa_print @spa
EXEC spa_run_sp_as_job @job_name, @spa, 'CopyMTM', @user_login_id
if @flag='c'
Exec spa_ErrorHandler 0, 'CopyMTM', 
			'process run', 'Status', 
			'Copy MTM process has been ran and will complete shortly.', 
			'Please Check/Refresh your message board.'

else
	Exec spa_ErrorHandler 0, 'CopyMTM', 
			'process run', 'Status', 
			'Delete MTM process has been ran and will complete shortly.', 
			'Please Check/Refresh your message board.'













