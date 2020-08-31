IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_initialize_deal_detail_hour_import_from_staging]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_initialize_deal_detail_hour_import_from_staging]
GO

-- ===============================================================================================================  
-- Create date: 2011-05-09 04:47PM  
-- Description: Truncates staging table before loading deal detail hour data. Also creates temp table for identifying
--				last job. 
-- ===============================================================================================================  
  
CREATE PROCEDURE dbo.spa_initialize_deal_detail_hour_import_from_staging
	@process_id VARCHAR(50),
	@user_login_id VARCHAR(50) = NULL
AS  
BEGIN  
	SET NOCOUNT ON;  

	DECLARE @partition_no INT, @partition_count INT  
	DECLARE @stage_table_name VARCHAR(300)
	DECLARE @sql VARCHAR(5000)
	DECLARE @tbl_final_import_run_status VARCHAR(150) 

	SET @partition_no = 1
	
	IF @user_login_id IS NULL
		SET @user_login_id = dbo.FNADBUser()

	--TODO: test purpose, remove in production code  
	UPDATE dbo.log_partition 
	SET end_time = NULL, start_time = NULL, data_found_status = 0, process_id = NULL, sp_end_time = NULL, sp_start_time = NULL
	, error_found_status = 0 
	WHERE tbl_name = 'deal_detail_hour'  

	SELECT @partition_count = MAX(partition_id) FROM log_partition WHERE tbl_name = 'deal_detail_hour'  

	WHILE @partition_no <= @partition_count  
	BEGIN  
		SET @stage_table_name = 'stage_deal_detail_hour_' + RIGHT('000' + CAST(@partition_no AS VARCHAR(5)), 3)  
		SET @sql = 'IF OBJECT_ID(N''' + @stage_table_name + ''', N''U'') IS NOT NULL DELETE FROM ' + @stage_table_name + ';'  
		exec spa_print @sql    
		EXEC(@sql)    
		SET @partition_no = @partition_no + 1  
	END

	--TODO: find a better solution, truncate doesn't work
	DELETE FROM dbo.report_hourly_position_profile_blank  
	DELETE FROM dbo.deal_detail_hour_blank
	
	SET @tbl_final_import_run_status = dbo.FNAProcessTableName('ddh_import_ssis_final_status', @user_login_id, @process_id)
	IF OBJECT_ID(@tbl_final_import_run_status) IS NOT NULL
		EXEC('DROP TABLE ' + @tbl_final_import_run_status)

	EXEC('CREATE TABLE ' + @tbl_final_import_run_status + ' (id INT, process_id VARCHAR(50), create_ts DATETIME)')
	EXEC('CREATE UNIQUE INDEX uindex_final_import_run_status ON ' +@tbl_final_import_run_status + ' (id)')
       
END  