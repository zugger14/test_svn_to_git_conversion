
IF OBJECT_ID(N'spa_calc_VAR', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_calc_VAR]
 GO 
/*
EXEC spa_calc_VAR '2009-01-01',1
*/

create PROCEDURE [dbo].spa_calc_VAR  
	@as_of_date varchar(20),
	@var_criteria_id INT,
	@whatif_criteria_id int=null,
@calc_type varchar(1) = 'r',
@tbl_name varchar(200)=null,
@measurement_approach INT=null,@conf_interval INT=null,@hold_period INT=NULL

AS

DECLARE @spa varchar(500),@process_id varchar(50)
DECLARE @job_name varchar(100)
declare @user_login_id varchar(50)
set @user_login_id=dbo.fnadbuser()
SET @process_id = REPLACE(newid(),'-','_')
SET @job_name = 'VaR_' + @process_id



SET @spa = 'spa_calc_VAR_job ''' + @as_of_date + ''', ' + cast(@var_criteria_id as varchar) + ',null,null,null,null,null,null, ''' +
			@process_id + ''', ''' + @job_name + ''''

exec spa_print @spa

EXEC spa_run_sp_as_job @job_name, @spa, 'VaR', @user_login_id

DECLARE @desc varchar(1000)
set @desc = 'VaR Calculation  process has been scheduled to run as of date ' + dbo.FNADateFormat(@as_of_date) +
			'. Please refresh the message board to check the process completion status.'

EXEC  spa_message_board 'i', @user_login_id,
				NULL, 'VaR',
				@desc, '', '', 's', @job_name


Exec spa_ErrorHandler 0, 'VaR', 
			'process run', 'Status', 
			'Your process has been run and will complete shortly. Please check/refresh your message board.', 
			''



















