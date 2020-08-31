IF OBJECT_ID(N'spb_Process_Transactions_As_Job', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spb_Process_Transactions_As_Job]
GO 

--exec spb_Process_Transactions_As_Job 'urbaral'
--drop proc spb_Process_Transactions_As_Job

CREATE PROC dbo.spb_Process_Transactions_As_Job 
	@user_id VARCHAR(50),
	@table_name VARCHAR(100)
AS
 
--BEGIN
 

--EXEC msdb.dbo.sp_start_job @job_name = 'Process_Deal_CSV'

--EXEC msdb.dbo.sp_delete_job @job_name='Process_Deal_CSV'

declare @job_name varchar(50)
--declare @db_name varchar(50)
declare @process_id varchar(50)
declare @spa varchar(1000)

SET @process_id = REPLACE(newid(),'-','_')
SET @job_name = 'REC_' + @process_id
--SET @db_name = db_name()


set @spa = 'spb_Process_Transactions 	''' + @user_id + ''', ''' + @table_name + '''' 

EXEC spa_run_sp_as_job @job_name, @spa, 'ImportRECs', @user_id 
						

Exec spa_ErrorHandler 0, 'Import RECs', 
			'Import RECS', 'Status', 
			'Import of REC Transactions has been scheduled and will complete shortly.', 
			'Please check/refresh your message board.'


-- -- EXEC msdb.dbo.sp_add_job @job_name = @run_job_name, 
-- --    @enabled = 1,
-- --    @start_step_id =1,
-- --    @owner_login_name = 'sa',
-- --    @notify_level_eventlog = 2,
-- --    @notify_level_email = 2,
-- --    @notify_level_netsend = 2,
-- --    @notify_level_page = 2,
-- --    @delete_level = 1
-- 
-- 
-- EXEC msdb.dbo.sp_add_job @job_name = @run_job_name,
-- 				@delete_level = 1
-- 
-- -- EXEC msdb.dbo.sp_add_jobserver @job_name = @run_job_name, 
-- --    @server_name = 'PS_UBARAL1\PS_UBARAL1'
-- 
-- EXEC msdb.dbo.sp_add_jobstep 
-- 	@job_name = @run_job_name ,
-- 	@step_id =1, 
-- 	@step_name = 'ImportCSV' , 
-- 	@subsystem = 'CMDEXEC',
-- 	@on_success_action = 3,
-- 	@command =  'DTSRun /~Z0x647CE21E272D1A06A63F0C2A42360AC30BE328673A6193000698A336D92BA0F6DD3FBF29A27327B7AAAC268EDE471B8A2BDD91B7FF4EB2E2D1872E9F01882D0A16F4BFAC6F3B9DA58DD530E0933AD7EDA201B8EC7157A81AE08F8C9F2379423CC4162C',		      
-- 	@database_name = @db_name
-- 		      
-- 
-- 
-- Declare @commandSP varchar(100)
-- SET @commandSP = 'EXEC ' + @db_name + '.dbo.spb_Process_Transactions ''' + @user_id + ''''
-- 
-- EXEC msdb.dbo.sp_add_jobstep 
-- 	@job_name = @run_job_name , 	
-- 	@step_id =2,
-- 	@step_name = 'ProcessData' , 
-- 	@subsystem = 'TSQL',
-- 	@command =  @commandSP,
-- 	@database_name = @db_name
-- 
-- 
-- EXEC msdb.dbo.sp_add_jobserver @job_name = @run_job_name
-- 
-- EXEC msdb.dbo.sp_start_job @job_name = @run_job_name
-- 
-- declare @desc varchar(500)
-- set @desc='Import of REC Transactions has been scheduled and will complete shortly.'
-- 
-- 
-- IF @@ERROR > 0
-- BEGIN
-- 
-- 	--declare @desc varchar(200)
-- 	SET @desc = 'Failed to run schedule process ' + @run_job_name
-- 	EXEC  spa_message_board 'i', @user_id, NULL, 'Import RECs',
-- 			 @desc, '', '', 'e', NULL
-- END
-- 
-- --print @desc
-- Exec spa_ErrorHandler 0, 'Import RECs', 
-- 			'Import RECS', 'Status', 
-- 			@desc, 
-- 			'Plese check/refresh your message board.'
-- 
-- 
-- END
-- 
-- 
--


