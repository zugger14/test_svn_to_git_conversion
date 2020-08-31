IF OBJECT_ID(N'spa_create_forecasted_transaction', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_create_forecasted_transaction]
GO 





-- exec spa_create_forecasted_transaction 'u', 1, 'urbaral'

-- to test proc use hedge as deal id 3 (1103), eff test profile id =4 and link date 1/4/2003
--This procedure creats forecasted transactions. 
-- Inputs are:
--@gen_flag = The default value 'u' means create transactions only for the the logged on user
-- 	      'a' the default value  means for all users
--@outstanding_minutes = 30 which means also create transactions that have not been
--			created within last 30 minutes (i..e, gen groups that have
--			not been processed yet)


create PROCEDURE [dbo].[spa_create_forecasted_transaction] 	@gen_flag VARCHAR(1) = 'u',
							@outstanding_minutes INT = 30,
							@user_login_id varchar(50),@as_of_date varchar(10)
						
AS


DECLARE @spa varchar(500)
DECLARE @job_name varchar(100)
DECLARE @process_id varchar(50)

SET @process_id = REPLACE(newid(),'-','_')
SET @job_name = 'ftgen_' + @process_id

If @gen_flag IS NULL 
	SET @gen_flag = 'u'

If @outstanding_minutes IS NULL 
	SET @outstanding_minutes = 30

SET @spa = 'spa_create_forecasted_transaction_job ''' + @gen_flag + ''', ' + 
		cast(@outstanding_minutes as varchar) + ', ''' + @job_name + ''', ''' + @user_login_id + ''','''+@as_of_date+''''

exec spa_print @spa


EXEC spa_run_sp_as_job @job_name, @spa, 'FTGeneration', @user_login_id

Exec spa_ErrorHandler 0, 'FTGeneration', 
			'process run', 'Status', 
			'Your forecasted transaction generation process has been run and will complete shortly.', 
			'Please check/refresh your message board.'








