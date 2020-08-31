IF OBJECT_ID(N'[dbo].[spa_calc_credit_exposure]', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_calc_credit_exposure]
go
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go





CREATE PROCEDURE [dbo].[spa_calc_credit_exposure]

			@as_of_date VARCHAR(20),
			@curve_source_value_id int, 
			@sub_entity_id VARCHAR(100) = NULL,	
			@strategy_entity_id VARCHAR(100) = NULL,
			@book_entity_id VARCHAR(100) = NULL,																							
			@counterparty_id INT = NULL,
			@purge_all CHAR(1) = 'n',	
			@what_if_group CHAR(1) = 'n'
as 

DECLARE @spa varchar(5000)
DECLARE @job_name varchar(100)
DECLARE @process_id varchar(50)
DECLARE @run_date datetime
DECLARE @desc varchar(500)
declare @user_login_id varchar(30)

 set @user_login_id=dbo.fnadbuser()

BEGIN TRY

SET @process_id = REPLACE(newid(),'-','_')
SET @job_name = 'calc_credit_exposure_'+@process_id

--If @sub_entity_id IS NULL 
--	SET @sub_entity_id = ''
--
--If @strategy_entity_id IS NULL 
--	SET @strategy_entity_id = ''
--
--If @book_entity_id IS NULL 
--	SET @book_entity_id = ''


SET @spa = 'spa_Calc_Credit_Netting_Exposure ''''' + dbo.FNAGetSQLStandardDate(@as_of_date) + ''''',''''' + @user_login_id+ ''''',''''' + @process_id + ''''',' + cast(@curve_source_value_id as varchar) +''

IF(@sub_entity_id IS NULL)
	SET @spa=@spa +' ,NULL'
ELSE
	SET @spa=@spa +' ,'''''+@sub_entity_id +''''''

IF(@strategy_entity_id IS NULL)
	SET @spa=@spa +' ,NULL'
ELSE
	SET @spa=@spa +' ,'''''+@strategy_entity_id +''''''

IF(@book_entity_id IS NULL)
	SET @spa=@spa +' ,NULL'
ELSE
	SET @spa=@spa +' ,'''''+@book_entity_id +''''''

IF(@counterparty_id IS NULL)
	SET @spa=@spa +' ,NULL'
ELSE
	SET @spa=@spa +' ,'''''+CAST(@counterparty_id as varchar)+''''''

IF(@purge_all IS NULL)
	SET @spa=@spa +' ,NULL'
ELSE
	SET @spa=@spa +' ,'''''+@purge_all +''''''

IF(@what_if_group IS NULL)
	SET @spa=@spa +' ,NULL'
ELSE
	SET @spa=@spa +' ,'''''+@what_if_group +''''''


EXEC spa_print @spa
DECLARE @query VARCHAR(MAX)

 SET @query = 'EXEC spa_run_sp_as_job '''+ @job_name +''','''+ @spa +''',''Calculate Credit Exposure'','+ @user_login_id


EXEC (@query)


set @desc='Calculate Credit Exposure  as of date '+dbo.FNADateFormat(@as_of_date)+ ' has been run and will complete shortly.'

EXEC spa_print @desc

Exec spa_ErrorHandler 0, 'Calculate Credit Exposure', 
			'Process run', 'Status',@desc, 
			'Please check/refresh your message board.'


END TRY
BEGIN CATCH
	--EXEC spa_print 'Error Found in Catch: ' + ERROR_MESSAGE()
		
	Select 'Error' ErrorCode, 'Run Calculate Credit Exposure' Module, 'spa_calc_credit_exposure','Error' Status, 
		('SQL Error Found: ' + ERROR_MESSAGE())  Message,'' Recommendation		
	
END CATCH
