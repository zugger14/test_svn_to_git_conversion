IF OBJECT_ID(N'spa_run_multi_assessment_job', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_run_multi_assessment_job]
GO 

-- drop proc spa_run_multi_assessment_job
--Call run mutli assessment that calls the dll to run multi assessment from the front end
--exec spa_run_multi_assessment_job 'urbaral', 'adihaiswonderful', 'PS_UBARAL1\PS_UBARAL1', 'adiha', '1', '', '', '', 'o', '3/2/2004', '121212xxx', 'test_jobxxx' 

CREATE PROCEDURE [dbo].[spa_run_multi_assessment_job]
	@user_id varchar(50),
	@user_pwd varchar(50),
	@server_name varchar(50),
	@database_name varchar(50),
	@sub_id varchar(1000),
	@strategy_id varchar(1000),
	@book_id varchar(1000),
	@assessment_id varchar(1000),
	@initial_ongoing varchar(1),
	@run_date varchar(1000),
	@process_id varchar(50),
	@job_name varchar(100)
AS
BEGIN
-- Declare @db_username varchar(50)
-- Declare @db_userpwd varchar(50)
-- declare @db_serverName varchar(50)
-- Declare @db_databaseName varchar(50)
--select  @db_userName=db_username,@db_userpwd=db_userpwd,@db_ServerName=db_serverName,@db_databaseName=db_databaseName from Connection_String


--convert to sql std date
SET @run_date = dbo.FNAGetSQLStandardDate(@run_date)

DECLARE @oUpdate     INT
DECLARE @resultCode  INT
DECLARE @rVal        VARCHAR(1000)
DECLARE @rVal1       INT

EXEC @resultcode  = sp_OACreate 'PSAASSMT.DLCRunMultiAssessment', @oUpdate OUT 
--print @resultCode
EXEC @rVal = sp_OAMethod @oUpdate, 'setConnectionString',null,@user_id,@user_pwd,@server_name,@database_name
--print @rVal
EXEC @resultcode = sp_OAMethod @oUpdate, 'runAssessment',@rVal1 out,@sub_id ,@strategy_id,@book_id,@assessment_id,@initial_ongoing,@run_date, @process_id
--print @resultCode
EXEC @resultCode = sp_OADestroy @oUpdate


DECLARE @url varchar(500)
DECLARE @urlP varchar(500)
DECLARE @url_desc varchar(8000)
DECLARE @user_name varchar(50)
DECLARE @desc varchar(8000)

SET @user_name = @user_id
--SET @desc = 'Assessment process completed for run date ' + @run_date 
SET @url_desc = 'Detail...'
SET @url = './dev/spa_html.php?__user_name__=' + @user_name + 
	'&spa=exec spa_get_eff_ass_test_run_log ''' + @process_id + ''''

SET @urlP = './dev/spa_perform_process.php?as_of_date=' + @run_date + 
	'&process_id=53&process_attachment=Run Assessment ran on ' +
	dbo.FNADateTimeFormat(getdate(), 1) +
	'&spa=exec spa_get_eff_ass_test_run_log ''' + @process_id + '''' +
	'&__user_name__=' + @user_id

SET @url_desc = '<a target="_blank" href="' + @urlP + '">' + 
	'Processed...' +
	'</a>'

DECLARE @error_count int
DECLARE @type char

SELECT  @error_count =   COUNT(*) 
FROM         fas_eff_ass_test_run_log
WHERE     process_id = @process_id AND code = 'Error'

If @error_count > 0 
	SET @type = 'e'
Else
	SET @type = 's'

SET @desc = '<a target="_blank" href="' + @url + '">' + 
		'Assessment process completed for run date ' + dbo.FNAUserDateFormat(@run_date, @user_id) + 
		case when (@type = 'e') then ' (ERRORS found)' else '' end +
		'.</a>'


EXEC  spa_message_board 'i', @user_name,
			NULL, 'Assessment',
			@desc, @url_desc, '', @type, @job_name

return 


end














