IF OBJECT_ID(N'runAssessment_main_job', N'P') IS NOT NULL
DROP PROCEDURE dbo.[runAssessment_main_job]
 GO 



---exec runAssessment_main_job NULL, NULL, '226', '1026312', 'o', '2008-01-26','farrms_admin'

-- exec spa_run_multi_assessment 'urbaral', 'adihaiswonderful', 'PS_UBARAL1\PS_UBARAL1', 'adiha', '1', '', '', '', 'o', '3/2/2004'

create PROCEDURE [dbo].[runAssessment_main_job]
@sub_id varchar(1000),
@strategy_id varchar(1000),
@book_id varchar(1000),
@assessment_id varchar(1000),
@initial_ongoing varchar(1),
@run_date varchar(10),
@user_name varchar(50)='farrms_admin'
AS

DECLARE @spa varchar(500)
DECLARE @job_name varchar(100)
DECLARE @process_id varchar(50)
declare @par varchar(1000)
SET @process_id = REPLACE(newid(),'-','_')
SET @job_name = 'assmt_' + @process_id

If @sub_id IS NULL 
	SET @par = 'null'
else
	SET @par = ''''+@sub_id+''''


If @strategy_id IS NULL 
	SET @par = @par+',null'
else
	SET @par = @par+','''+@strategy_id+''''
If @book_id IS NULL 
	SET @par = @par+',null'
else
	SET @par = @par+','''+@book_id+''''
if @assessment_id is null
	SET @par = @par+',null'
else
	SET @par = @par+','''+@assessment_id+''''

SET @par = @par+',''' +@initial_ongoing + ''', '''
		+@run_date + ''', '''
		+@user_name+ ''','''
		+@process_id + ''''



SET @spa = 'runAssessment_main '+@par
--print @spa
--return
EXEC spa_run_sp_as_job @job_name, @spa, 'Assessment',@user_name

Exec spa_ErrorHandler 0, 'Assessment', 
			'Process run', 'Status', 
			'Assessment of hedge effectiveness testing process has been run and will complete shortly.', 
			'Please check/refresh your message board.'












