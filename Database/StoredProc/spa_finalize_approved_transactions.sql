IF OBJECT_ID(N'spa_finalize_approved_transactions', N'P') IS NOT NULL
	DROP PROCEDURE spa_finalize_approved_transactions
GO 

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
This is a wrapper SP for spa_finalize_approved_transactions_job which creates job
	Parameters: 
	@gen_flag 			  : The default value 'u' means create transactions only for the the logged on user
						    'a' the default value  means for all users
	@outstanding_minutes  :  30 which means also create transactions that have not been
							 created within last 30 minutes (i..e, transactions that have
							 not been processed yet)
	@user_login_id 		  : User name
	@gen_group_id  		  : Gen hedge group id
	@batch_process_id     : Batch Unqiue identifier
	@batch_report_param   : Batach Paramaters

*/

CREATE PROCEDURE [dbo].[spa_finalize_approved_transactions]  
	@gen_flag VARCHAR(1) = 'u',
	@outstanding_minutes INT = 30,
	@user_login_id VARCHAR(50),
	@gen_group_id VARCHAR(MAX) = NULL,
	@batch_process_id    VARCHAR(50) = NULL, 
	@batch_report_param  VARCHAR(1000) = NULL
					
AS

SET ANSI_NULLS ON
SET NOCOUNT ON
SET QUOTED_IDENTIFIER ON

IF @gen_flag IS NULL 
	SET @gen_flag = 'u'

IF @outstanding_minutes IS NULL 
	SET @outstanding_minutes = 30

DECLARE @spa VARCHAR(MAX)
DECLARE @job_name VARCHAR(MAX)
DECLARE @process_id VARCHAR(MAX)

SET @process_id = ISNULL(@batch_process_id, dbo.FNAGetNewID())
SET @job_name = 'ftfin_' + @process_id

SET @spa = 'spa_finalize_approved_transactions_job ''' + @gen_flag + ''', ' + 
		CAST(@outstanding_minutes AS VARCHAR) + ', ''' + @job_name + ''', ''' + @user_login_id + ''','''+ @process_id +''',''' + @gen_group_id + '''' 

--print (@spa)
EXEC spa_run_sp_as_job @job_name, @spa, 'FTFinalize', @user_login_id

EXEC spa_ErrorHandler 0, 'FTFinalize', 
			'process run', 'Status', 
			'Your finalization of approved transactions process has been run and will complete shortly.', 
			'Please check/refresh your message board.'

GO




