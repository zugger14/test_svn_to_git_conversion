IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_deal_transfer_alert_wrapper]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_deal_transfer_alert_wrapper]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/**
	Wrapper SP to call auto schedule of any failt to auto schedule deal.

	Parameters 
	@process_id : Process ID.

*/

CREATE PROC [dbo].[spa_deal_transfer_alert_wrapper]
	@process_id NVARCHAR(100) = NULL	
AS
BEGIN 
	DECLARE @source_deal_header_ids VARCHAR(MAX)
	DECLARE @sql VARCHAR(MAX)
	DECLARE @total_columns VARCHAR(100)

	IF OBJECT_ID('tempdb..#resultdatatable') IS NOT NULL 
       DROP TABLE #resultdatatable
	CREATE TABLE #resultdatatable(dummy_column int)


	SELECT @source_deal_header_ids = ISNULL(@source_deal_header_ids + ',', '') + CAST(source_Deal_header_id AS VARCHAR(10))
	FROM 
	(
		SELECT DISTINCT source_Deal_header_id
		FROM process_deal_alert_transfer_adjust
		WHERE process_id =  @process_id
	) sub
	
	SET @sql =  ' [spa_deal_transfer_alert] ''r'', ''' + @source_deal_header_ids + ''',''' +  @process_id + ''''
	-- select @sql

	DECLARE @job_process_id VARCHAR(200) = dbo.FNAGETNEWID()
	DECLARE @job_name  VARCHAR(500)
	DECLARE @user_name  VARCHAR(100) = dbo.FNADBUser()
	
	-- SET @sql = 'spa_deal_insert_update_jobs ''i'', ''' + @after_insert_process_table + ''''
	SET @job_name = 'auto_schedule_' + @user_name + '_' + @job_process_id 	
	
	
	EXEC spa_run_sp_as_job @job_name, @sql, 'spa_deal_transfer_alert_wrapper', @user_name
	
	/*EXEC spa_get_output_schema_or_data @sql_query = @sql
		,@process_table_name = '#resultdatatable'
		,@data_output_col_count = @total_columns OUTPUT
		,@flag = 'data'
		*/

END 