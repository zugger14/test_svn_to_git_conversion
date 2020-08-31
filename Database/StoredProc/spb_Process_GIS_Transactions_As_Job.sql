IF OBJECT_ID(N'spb_Process_GIS_Transactions_As_Job', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spb_Process_GIS_Transactions_As_Job]
 GO 




--exec spb_Process_GIS_Transactions_As_Job 'urbaral'
--drop proc spb_Process_GIS_Transactions_As_Job

CREATE PROC [dbo].[spb_Process_GIS_Transactions_As_Job] 
	@user_id varchar(50), 
	@table_name varchar(100)
AS
 
--BEGIN
 

--EXEC msdb.dbo.sp_start_job @job_name = 'Process_Deal_CSV'

--EXEC msdb.dbo.sp_delete_job @job_name='Process_Deal_CSV'

declare @job_name varchar(50)
--declare @db_name varchar(50)
declare @process_id varchar(50)
declare @spa varchar(1000)

set @process_id = REPLACE(newid(),'-','_')
SET @job_name = 'GIS_REC_' + @process_id
--SET @db_name = db_name()

set @spa = 'spa_Reconcile_GIS_Transactions ''' + @user_id + ''',''' + @table_name + ''', null, null, null, null, ' +
		'''' + @process_id + ''', ''' + @job_name + ''''



EXEC spa_run_sp_as_job @job_name, @spa, 'ImportGISRECs', @user_id 

Exec spa_ErrorHandler 0, 'Import GIS RECs', 
			'Import GIS RECS', 'Status', 
			'Import of GIS REC Transactions has been scheduled and will complete shortly.', 
			'Please check/refresh your message board.'


-- EXEC msdb.dbo.sp_add_job @job_name = @run_job_name,
-- 				@delete_level = 1
-- 
-- EXEC msdb.dbo.sp_add_jobstep 
-- 	@job_name = @run_job_name ,
-- 	@step_id =1, 
-- 	@step_name = 'ImportGISCSV' , 
-- 	@subsystem = 'CMDEXEC',
-- 	@on_success_action = 3,
-- 	@command =  'DTSRun /~Z0x2A3AD01B739C89B91D73FBAB51ACC9AC4DD7E951599C327EBBDBA2DE2375F6240B84B246DC012EF5331D2E869438F43B75E2FAA2CEFE46DD1E9AF4ED5B4AFB8974B1239D323C270301A3D0BB52295B3A4819EC5C6F82500FF153E21A19924F3048941D',		      
-- 	@database_name = @db_name
-- 		      
-- 
-- Declare @commandSP varchar(1000)
-- SET @commandSP = 'EXEC ' + @db_name + '.dbo.spa_Reconcile_GIS_Transactions ''' + @user_id + ''', null, null, null, null, ' +
-- 		'''' + @process_id + ''', ''' + @run_job_name + ''''
-- 
--  
-- EXEC msdb.dbo.sp_add_jobstep 
-- 	@job_name = @run_job_name , 	
-- 	@step_id =2,
-- 	@step_name = 'ReconGISData' , 
-- 	@subsystem = 'TSQL',
-- 	@command =  @commandSP,
-- 	@database_name = @db_name
-- 
-- EXEC msdb.dbo.sp_add_jobserver @job_name = @run_job_name
-- 
-- EXEC msdb.dbo.sp_start_job @job_name = @run_job_name
-- 
-- declare @desc varchar(500)
-- set @desc='Import of GIS REC Transactions has been scheduled and will complete shortly.'
-- 
-- 
-- IF @@ERROR > 0
-- BEGIN
-- 
-- 	--declare @desc varchar(200)
-- 	SET @desc = 'Failed to run GIS REC Transactions schedule process ' + @run_job_name
-- 	EXEC  spa_message_board 'i', @user_id, NULL, 'Import RECs',
-- 			 @desc, '', '', 'e', NULL
-- END
-- 
-- --print @desc
-- Exec spa_ErrorHandler 0, 'Import GIS RECs', 
-- 			'Import GIS RECS', 'Status', 
-- 			@desc, 
-- 			'Plese check/refresh your message board.'


--END


