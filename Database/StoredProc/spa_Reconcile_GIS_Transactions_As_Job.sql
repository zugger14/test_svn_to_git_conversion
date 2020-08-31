IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_Reconcile_GIS_Transactions_As_Job]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Reconcile_GIS_Transactions_As_Job]
GO 



--exec spa_Reconcile_GIS_Transactions_As_Job 'urbaral',  '2006-01-01', '2006-01-31'
--drop proc spa_Reconcile_GIS_Transactions_As_Job

CREATE PROC [dbo].[spa_Reconcile_GIS_Transactions_As_Job] 
			@user_id varchar(50),
			@gen_date_from  varchar(20) = null,
			@gen_date_to  varchar(20) = null,
			@generator_id  int = null,
			@gis_value_id int = null
AS
 
BEGIN
 

--EXEC msdb.dbo.sp_start_job @job_name = 'Process_Deal_CSV'

--EXEC msdb.dbo.sp_delete_job @job_name='Process_Deal_CSV'

declare @job_name varchar(50)
--declare @db_name varchar(50)
declare @process_id varchar(100)

set @process_id = REPLACE(newid(),'-','_')
SET @job_name = 'GIS_' + @process_id

--SET @db_name = db_name()

declare @desc varchar(500)
declare @spa varchar(5000)
set @desc='REC Transactions Reconciliation with GIS has been scheduled and will complete shortly.'


SET @spa = 'spa_Reconcile_GIS_Transactions ''' + @user_id + ''',  ' +
		case when (@gen_date_from is null) then 'NULL' else '''' + @gen_date_from + '''' end + ', ' +
		case when (@gen_date_to is null) then 'NULL' else '''' + @gen_date_to + '''' end + ', ' +
		case when (@generator_id is null) then 'NULL' else cast(@generator_id as varchar) end + ', ' +
		case when (@gis_value_id is null) then 'NULL' else cast(@gis_value_id as varchar) end + ', ' +
		'''' + @process_id + ''', ' +
		'''' + @job_name + '''' 
				
--print @spa
-- 
-- Return

EXEC spa_run_sp_as_job @job_name, @spa, 'GIS Reconciliation', @user_id


IF @@ERROR > 0
BEGIN

	--declare @desc varchar(200)
	SET @desc = 'Failed to run REC Transactions Reconciliation with GIS schedule process.' + @job_name
	EXEC  spa_message_board 'i', @user_id, NULL, 'GIS Reconciliation',
			 @desc, '', '', 'e', NULL
END


Exec spa_ErrorHandler 0, 'Assign Transactions', 
			'spa_assign_rec_deals_job', 'Status', 
			'Assignment of REC Transactions has been run and will complete shortly.', 
			'Please check/refresh your message board.'


END


