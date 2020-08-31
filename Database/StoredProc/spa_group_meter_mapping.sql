IF OBJECT_ID(N'[dbo].[spa_group_meter_mapping]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_group_meter_mapping]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2011-12-16
-- Description: CRUD operations for table group_meter_mapping

-- Params:
-- @flag CHAR(1) - Operation flag
-- @counterparty_id INT - Counterparty id.
-- @region_id INT - Region Id.
-- @grid_id - Grid id.
-- @category_id INT - Category Id.
-- @pv_party_id INT - Pv Party ID.
-- @meter_id INT - Meter id.
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_group_meter_mapping]
	@flag CHAR(1),
	@group_meter_mapping_id INT = NULL,
	@counterparty_id INT = NULL,
	@region_id INT = NULL,
	@grid_id INT = NULL,
	@category_id INT = NULL,
	@pv_party_id INT = NULL,
	@meter_id INT = NULL,
	@aggregate_to_meter INT = NULL
AS
	
IF @flag = 's'
BEGIN
    SELECT gmm.group_meter_mapping_id AS [Group Meter Mapping ID],
           sc.counterparty_name AS [Counterparty],
           sdv1.code [Region],
           sdv2.code [Grid],
           sdv3.code [Category],
           --sdv4.code [PV Party],
           mi.recorderid [Meter ID],
           aggmi.recorderid [Aggregate to Meter]
    FROM   group_meter_mapping gmm
    LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = gmm.counterparty_id
    LEFT JOIN meter_id mi ON mi.meter_id = gmm.meter_id
    LEFT JOIN meter_id aggmi ON aggmi.meter_id = gmm.aggregate_to_meter
    LEFT JOIN static_data_value sdv1 ON sdv1.value_id = gmm.region_id
    LEFT JOIN static_data_value sdv2 ON sdv2.value_id = gmm.grid_id
    LEFT JOIN static_data_value sdv3 ON sdv3.value_id = gmm.category_id
    --LEFT JOIN static_data_value sdv4 ON sdv4.value_id = gmm.pv_party_id
END
IF @flag = 'a'
BEGIN
    SELECT gmm.group_meter_mapping_id,
           gmm.counterparty_id,
           gmm.region_id,
           gmm.grid_id,
           gmm.category_id,
           gmm.pv_party_id,
           gmm.meter_id,
           mi.recorderid,
           gmm.aggregate_to_meter,
           aggmi.recorderid           
    FROM   group_meter_mapping gmm
    LEFT JOIN meter_id mi ON mi.meter_id = gmm.meter_id
    LEFT JOIN meter_id aggmi ON aggmi.meter_id = gmm.aggregate_to_meter
    WHERE  gmm.group_meter_mapping_id = @group_meter_mapping_id
END
IF @flag = 'i'
BEGIN
    BEGIN TRY
    	BEGIN TRANSACTION
    	INSERT INTO group_meter_mapping
    	  (
    	    counterparty_id,
    	    region_id,
    	    grid_id,
    	    category_id,
    	    pv_party_id,
    	    meter_id,
    	    aggregate_to_meter
    	  )
    	VALUES
    	  (
    	    @counterparty_id,
    	    @region_id,
    	    @grid_id,
    	    @category_id,
    	    @pv_party_id,
    	    @meter_id,
    	    @aggregate_to_meter
    	  )
    	
    	COMMIT
    	
    	EXEC spa_ErrorHandler 0,
    	     'Group Meter Mapping',
    	     'spa_group_meter_mapping',
    	     'Success',
    	     'Data Successfully Inserted.',
    	     ''
    END TRY
    BEGIN CATCH
    	IF @@TRANCOUNT > 0
    	    ROLLBACK TRAN
    	
    	DECLARE @err_msg VARCHAR(200)
    	SET @err_msg = ERROR_MESSAGE()
    	EXEC spa_ErrorHandler -1,
    	     'Group Meter Mapping',
    	     'spa_group_meter_mapping',
    	     'DB Error',
    	     'Failed Inserting Data.',
    	     @err_msg
    END CATCH
END
IF @flag = 'u'
BEGIN
    BEGIN TRY
    	BEGIN TRANSACTION
    	UPDATE group_meter_mapping
    	SET    counterparty_id = @counterparty_id,
    	       region_id = @region_id,
    	       grid_id = @grid_id,
    	       category_id = @category_id,
    	       pv_party_id = @pv_party_id,
    	       meter_id = @meter_id,
    	       aggregate_to_meter = @aggregate_to_meter
    	WHERE  group_meter_mapping_id = @group_meter_mapping_id 
    	
    	COMMIT 
    	EXEC spa_ErrorHandler 0,
    	     'Group Meter Mapping',
    	     'spa_group_meter_mapping',
    	     'Success',
    	     'Data Successfully Updated.',
    	     ''
    END TRY
    
    BEGIN CATCH
    	IF @@TRANCOUNT > 0
    	    ROLLBACK TRAN
    	
    	DECLARE @err_msg1 VARCHAR(200)
    	SET @err_msg1 = ERROR_MESSAGE()
    	EXEC spa_ErrorHandler -1,
    	     'Group Meter Mapping',
    	     'spa_group_meter_mapping',
    	     'DB Error',
    	     'Failed Updating Data.',
    	     @err_msg1
    END CATCH
END
IF @flag = 'd'
BEGIN
    BEGIN TRY
    	BEGIN TRANSACTION
    	DELETE 
    	FROM   group_meter_mapping
    	WHERE  group_meter_mapping_id = @group_meter_mapping_id
    	
    	COMMIT
    	EXEC spa_ErrorHandler 0,
    	     'Group Meter Mapping',
    	     'spa_group_meter_mapping',
    	     'Success',
    	     'Data Successfully Deleted.',
    	     ''
    END TRY
    BEGIN CATCH
    	IF @@TRANCOUNT > 0
    	    ROLLBACK TRAN
    	
    	DECLARE @err_msg2 VARCHAR(200)
    	SET @err_msg2 = ERROR_MESSAGE()
    	EXEC spa_ErrorHandler -1,
    	     'Group Meter Mapping',
    	     'spa_group_meter_mapping',
    	     'DB Error',
    	     'Failed Deleting Data.',
    	     @err_msg2
    END CATCH
END