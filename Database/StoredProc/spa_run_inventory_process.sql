IF OBJECT_ID('spa_run_inventory_process') IS NOT NULL
DROP PROCEDURE [dbo].[spa_run_inventory_process]
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

/**
	Stored procedure to run Inventory Process

	Parameters
	@as_of_date : As Of Date to run the process 
	@term_start : Term Start
	@term_end : Term End
	@wacog_group_name_id : Comma separated ids of Wacog Group Name
	@storage_asset_id : Comma separated ids of Storage Assets
	@lpds_sub_id : Comma separated ids of Subsidiary for Lease Purchase Deal Settlement
	@lpds_stra_id : Comma separated ids of Strategy for Lease Purchase Deal Settlement
	@lpds_book_id : Comma separated ids of Book for Lease Purchase Deal Settlement
	@lpds_sub_book_id : Comma separated ids of Sub Book for Lease Purchase Deal Settlement
	@lpds_source_deal_header_id : Comma separated ids of Deal for Lease Purchase Deal Settlement
	@lpods_sub_id : Comma separated ids of Subsidiary for Lease Pool Deal Settlement
	@lpods_stra_id : Comma separated ids of Storage Assets Lease Pool Deal Settlement
	@lpods_book_id : Comma separated ids of Sub Book for Lease Pool Deal Settlement
	@lpods_sub_book_id : Comma separated ids of Deal for Lease Pool Deal Settlement
	@lpods_source_deal_header_id : Comma separated ids of Deal for Lease Pool Deal Settlement
	@tds_sub_id : Comma separated ids of Subsidiary for Transportation Deal Settlement
	@tds_stra_id : Comma separated ids of Storage Assets Transportation Deal Settlement
	@tds_book_id : Comma separated ids of Book for Transportation Deal Settlement 
	@tds_sub_book_id : Comma separated ids of Sub Book for Transportation Deal Settlement
	@tds_source_deal_header_id : Comma separated ids of Deal for Transportation Deal Settlement
	@ids_sub_id : Comma separated ids of Subsidiary for Injection Deal Settlement
	@ids_stra_id : Comma separated ids of Storage Assets Injection Deal Settlement
	@ids_book_id : Comma separated ids of Book for Injection Deal Settlement 
	@ids_sub_book_id : Comma separated ids of Sub Book for Injection Deal Settlement
	@ids_source_deal_header_id : Comma separated ids of Deal for Injection Deal Settlement
*/
CREATE PROCEDURE [dbo].[spa_run_inventory_process]
	@as_of_date DATETIME = NULL,
	@term_start DATETIME = NULL,
	@term_end DATETIME = NULL,
	@wacog_group_name_id NVARCHAR(MAX) = NULL,
	@storage_asset_id NVARCHAR(MAX) = NULL,
	--Lease Purchase Deal Settlement
	@lpds_sub_id NVARCHAR(MAX) = NULL,
	@lpds_stra_id NVARCHAR(MAX) = NULL,
	@lpds_book_id NVARCHAR(MAX) = NULL,
	@lpds_sub_book_id NVARCHAR(MAX) = NULL,
	@lpds_source_deal_header_id NVARCHAR(MAX) = NULL,	
	--Lease Pool Deal Settlement
	@lpods_sub_id NVARCHAR(MAX) = NULL,
	@lpods_stra_id NVARCHAR(MAX) = NULL,
	@lpods_book_id NVARCHAR(MAX) = NULL,
	@lpods_sub_book_id NVARCHAR(MAX) = NULL,
	@lpods_source_deal_header_id NVARCHAR(MAX) = NULL,
	--Transportation Deal Settlement
	@tds_sub_id NVARCHAR(MAX) = NULL,
	@tds_stra_id NVARCHAR(MAX) = NULL,
	@tds_book_id NVARCHAR(MAX) = NULL,
	@tds_sub_book_id NVARCHAR(MAX) = NULL,
	@tds_source_deal_header_id NVARCHAR(MAX) = NULL,
	--Injection Deal Settlement
	@ids_sub_id NVARCHAR(MAX) = NULL,
	@ids_stra_id NVARCHAR(MAX) = NULL,
	@ids_book_id NVARCHAR(MAX) = NULL,
	@ids_sub_book_id NVARCHAR(MAX) = NULL,
	@ids_source_deal_header_id NVARCHAR(MAX) = NULL	
AS

SET NOCOUNT ON

SET @lpds_source_deal_header_id = IIF(@lpds_source_deal_header_id = '' OR @lpds_source_deal_header_id = 'NULL', NULL, @lpds_source_deal_header_id)
SET @lpods_source_deal_header_id = IIF(@lpods_source_deal_header_id = '' OR @lpods_source_deal_header_id = 'NULL', NULL, @lpods_source_deal_header_id)
SET @tds_source_deal_header_id = IIF(@tds_source_deal_header_id = '' OR @tds_source_deal_header_id = 'NULL', NULL, @tds_source_deal_header_id)
SET @ids_source_deal_header_id = IIF(@ids_source_deal_header_id = '' OR @ids_source_deal_header_id = 'NULL', NULL, @ids_source_deal_header_id)
SET @wacog_group_name_id = IIF(@wacog_group_name_id = '' OR @wacog_group_name_id = 'NULL', NULL, @wacog_group_name_id)
SET @storage_asset_id = IIF(@storage_asset_id = '' OR @storage_asset_id = 'NULL', NULL, @storage_asset_id)
SET @lpds_sub_book_id = IIF(@lpds_sub_book_id = '' OR @lpds_sub_book_id = 'NULL', NULL, @lpds_sub_book_id)
SET @lpods_sub_book_id = IIF(@lpods_sub_book_id = '' OR @lpods_sub_book_id = 'NULL', NULL, @lpods_sub_book_id)
SET @ids_sub_book_id = IIF(@ids_sub_book_id = '' OR @ids_sub_book_id = 'NULL', NULL, @ids_sub_book_id)

BEGIN
	-- STEP 1 Run Settlement for Lease Purchase deals Settlement
	EXEC spa_calc_mtm_job  @lpds_sub_id,@lpds_stra_id,@lpds_book_id,@lpds_sub_book_id,
	@lpds_source_deal_header_id, @as_of_date ,
	4500, --@curve_source_value_id
	4500, -- @pnl_source_value_id
	NULL,NULL , NULL,NULL, 
	NULL,-- @assessment_curve_type_value_id
	NULL,NULL,NULL,NULL,
	NULL,--@summary_detail
	NULL,NULL,NULL,
	NULL,--@run_incremental
	@term_start, @term_end,
	's', --@calc_type
	NULL,NULL,NULL,NULL,NULL,NULL

	-- STEP 2 Run WACOG Group
	EXEC spa_wacog_group 'r',
	@wacog_group_name_id,
	@as_of_date,
	@term_start,
	@term_end, 0

	-- STEP 3 Run Settlement for Lease Pool deals settlement
	EXEC spa_calc_mtm_job  @lpods_sub_id,@lpods_stra_id,@lpods_book_id,@lpods_sub_book_id,
	@lpods_source_deal_header_id, @as_of_date ,
	4500, --@curve_source_value_id
	4500, -- @pnl_source_value_id
	NULL,NULL , NULL,NULL, 
	NULL,-- @assessment_curve_type_value_id
	NULL,NULL,NULL,NULL,
	NULL,--@summary_detail
	NULL,NULL,NULL,
	NULL,--@run_incremental
	@term_start, @term_end,
	's', --@calc_type
	NULL,NULL,NULL,NULL,NULL,NULL
	
	-- STEP 4 Run Settlement for Transportation deals settlement
	EXEC spa_calc_mtm_job  @tds_sub_id,@tds_stra_id,@tds_book_id,@tds_sub_book_id,
	@tds_source_deal_header_id, @as_of_date ,
	4500, --@curve_source_value_id
	4500, -- @pnl_source_value_id
	NULL,NULL , NULL,NULL, 
	NULL,-- @assessment_curve_type_value_id
	NULL,NULL,NULL,NULL,
	NULL,--@summary_detail
	NULL,NULL,NULL,
	NULL,--@run_incremental
	@term_start, @term_end,
	's', --@calc_type
	NULL,NULL,NULL,NULL,NULL,NULL

	-- STEP 5 Run Settlement for Injection deals
	EXEC spa_calc_mtm_job  @ids_sub_id,@ids_stra_id,@ids_book_id,@ids_sub_book_id,
	@ids_source_deal_header_id, @as_of_date ,
	4500, --@curve_source_value_id
	4500, -- @pnl_source_value_id
	NULL,NULL , NULL,NULL, 
	NULL,-- @assessment_curve_type_value_id
	NULL,NULL,NULL,NULL,
	NULL,--@summary_detail
	NULL,NULL,NULL,
	NULL,--@run_incremental
	@term_start, @term_end,
	's', --@calc_type
	NULL,NULL,NULL,NULL,NULL,NULL
		
	DECLARE @batch_report_param NVARCHAR(MAX), @batch_process_id VARCHAR(100)
	SET @batch_process_id = dbo.FNAGetNewID()
	SET @batch_report_param  = 'spa_calc_storage_wacog @as_of_date=''' + CAST(@as_of_date AS VARCHAR(20)) + ''', @storage_assets_id=''' + @storage_asset_id + ''', @contract=NULL, @location_id=NULL, @term_start=''' + CAST(@term_start AS VARCHAR(20)) + ''', @term_end=''' + CAST(@term_end AS VARCHAR(20)) +''''

	-- STEP 6 Run Storage WACOG
	EXEC spa_calc_storage_wacog @as_of_date=@as_of_date, @storage_assets_id=@storage_asset_id, 
	@contract=NULL, @location_id=NULL, @term_start=@term_start, 
	@term_end=@term_end, @return_output=0,@batch_process_id = @batch_process_id, @batch_report_param = @batch_report_param	

	SET @batch_process_id = dbo.FNAGetNewID()
	-- STEP 7 Re run Storage WACOG calc
	EXEC spa_calc_storage_wacog @as_of_date=@as_of_date,
	 @storage_assets_id=@storage_asset_id, @contract=NULL, @location_id=NULL, 
	 @term_start=@term_start, @term_end=@term_end, @return_output=0, @batch_process_id = @batch_process_id, @batch_report_param = @batch_report_param	

END
