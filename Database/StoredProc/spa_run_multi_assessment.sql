IF OBJECT_ID(N'spa_run_multi_assessment', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_run_multi_assessment]
GO

-- exec spa_run_multi_assessment 'urbaral', 'adihaiswonderful', 'PS_UBARAL1\PS_UBARAL1', 'adiha', '1', '', '', '', 'o', '3/2/2004'

CREATE PROCEDURE [dbo].[spa_run_multi_assessment] 	
	@user_id varchar(50),
	@user_pwd varchar(50),
	@server_name varchar(50),
	@database_name varchar(50),
	@sub_id varchar(1000),
	@strategy_id varchar(1000),
	@book_id varchar(1000),
	@assessment_id varchar(1000),
	@initial_ongoing varchar(1),
	@run_date varchar(1000)
						
AS

DECLARE @spa varchar(500)
DECLARE @job_name varchar(100)
DECLARE @process_id varchar(50)

SET @process_id = REPLACE(newid(),'-','_')
SET @job_name = 'assmt_' + @process_id

If @sub_id IS NULL 
	SET @sub_id = ''

If @strategy_id IS NULL 
	SET @strategy_id = ''

If @book_id IS NULL 
	SET @book_id = ''

SET @spa = 'spa_run_multi_assessment_job ''' + @user_id + ''', ''' + @user_pwd + ''', ''' +
		@server_name + ''', ''' + @database_name + ''', ''' +
		@sub_id + ''', ''' + @strategy_id + ''', ''' +
		@book_id + ''', ''' + @assessment_id + ''', ''' + 
		@initial_ongoing + ''', ''' + @run_date + ''', ''' + 
		 @process_id + ''', ''' + @job_name + ''''


EXEC spa_run_sp_as_job @job_name, @spa, 'Assessment', @user_id

Exec spa_ErrorHandler 0, 'Assessment', 
			'Process run', 'Status', 
			'Your effectiveness testing process has been run and will complete shortly.', 
			'Plese check/refresh your message board.'








