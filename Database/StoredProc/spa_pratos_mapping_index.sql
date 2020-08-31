IF OBJECT_ID(N'[dbo].[spa_pratos_mapping_index]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_pratos_mapping_index]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: rtuladhar@pioneersolutionsglobal.com
-- Create date: 2011-06-06
-- Description: Pratos Mapping for index

-- Params:
--	@flag CHAR(1) - Operation flag
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_pratos_mapping_index]
    @flag CHAR(1),
    @pratos_source_price_curve_map_id INT = NULL,
    @location_group_id VARCHAR(500) = NULL,
    @region VARCHAR(255) = NULL,
    @grid_value_id VARCHAR(255) = NULL,
    @block_type VARCHAR(255) = NULL,
    @curve_id INT = NULL,
    @category_id INT = NULL,
    @country_id INT = NULL
AS

DECLARE @sql VARCHAR(MAX)

IF @flag = 's'
BEGIN
	SELECT pspcm.id AS [ID],
	       sml.location_name AS [Location Group],
	       sdv.[code] AS [Region],
	       sdv1.[code] AS [Grid],
	       pspcm.block_type AS [Block Type],
	       spcd.curve_name AS [Price Curve],
	       sdv2.[code] AS [Category],
	       sdv3.[code] AS [Country]
	       
	FROM   pratos_source_price_curve_map pspcm
	       INNER JOIN source_price_curve_def spcd ON  pspcm.curve_id = spcd.source_curve_def_id
	       LEFT JOIN source_major_location sml ON pspcm.location_group_id = sml.source_major_location_ID
	       LEFT JOIN static_data_value sdv ON sdv.value_id = pspcm.region AND sdv.type_id=11150
	       LEFT JOIN static_data_value sdv1 ON sdv1.value_id = pspcm.grid_value_id AND sdv1.type_id=18000
	       LEFT JOIN static_data_value sdv2 ON sdv2.value_id = pspcm.category_id AND sdv2.type_id=18100
	       LEFT JOIN static_data_value sdv3 ON sdv3.value_id = pspcm.country_id AND sdv3.type_id=14000
END

ELSE IF @flag = 'a'
BEGIN
	SELECT pspcm.id
		, pspcm.location_group_id
		, pspcm.region
		, pspcm.grid_value_id
		, pspcm.block_type
		, pspcm.curve_id
		, pspcm.category_id
		, pspcm.country_id
	FROM pratos_source_price_curve_map pspcm
	WHERE pspcm.id = @pratos_source_price_curve_map_id
END

ELSE IF @flag = 'i'
BEGIN
	BEGIN TRY
	BEGIN TRAN 
		INSERT INTO pratos_source_price_curve_map
		(
			location_group_id,
			region,
			grid_value_id,
			block_type,
			curve_id,
			category_id,
			country_id
		)
		VALUES
		(
			@location_group_id,
			@region,
			@grid_value_id,
			@block_type,
			@curve_id,
			@category_id,
			@country_id
		)
		COMMIT 
		
		DECLARE @last_id INT 
		SELECT @last_id = SCOPE_IDENTITY()
		EXEC spa_ErrorHandler 0
			, 'pratos_source_price_curve_map table'--tablename
			, 'spa_pratos_mapping_index'--sp
			, 'Success'--error type
			, 'Data insert successful Data.'
			, @last_id --personal msg
	END TRY
	BEGIN CATCH
		DECLARE @error VARCHAR(5000)
		SET @error = ERROR_MESSAGE()
		EXEC spa_ErrorHandler -1
			, 'pratos_source_price_curve_map table'--tablename
			, 'spa_pratos_mapping_index'--sp
			, 'DB Error'--error type
			, 'Failed inserting Data.'
			, @error --personal msg
			
		ROLLBACK 
		
	END CATCH
END

ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
	BEGIN TRAN 
	UPDATE pratos_source_price_curve_map
	SET
		location_group_id = @location_group_id
		, region = @region
		, grid_value_id = @grid_value_id
		, block_type = @block_type
		, curve_id = @curve_id
		, category_id = @category_id
		, country_id = @country_id
	WHERE id = @pratos_source_price_curve_map_id
	COMMIT 
		EXEC spa_ErrorHandler 0
			, 'pratos_source_price_curve_map table'--tablename
			, 'spa_pratos_mapping_index'--sp
			, 'Success'--error type
			, 'Data insert successful Data.'
			, @pratos_source_price_curve_map_id --personal msg
	END TRY
	BEGIN CATCH
		SET @error = ERROR_MESSAGE()
		EXEC spa_ErrorHandler -1
			, 'pratos_source_price_curve_map table'--tablename
			, 'spa_pratos_mapping_index'--sp
			, 'DB Error'--error type
			, 'Failed Updating Data.'
			, @error --personal msg
			
		ROLLBACK 
	END CATCH
END

ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
	BEGIN TRAN 
		DELETE FROM pratos_source_price_curve_map WHERE id = @pratos_source_price_curve_map_id
		
		COMMIT 
		
		EXEC spa_ErrorHandler 0
			, 'pratos_source_price_curve_map table'--tablename
			, 'spa_pratos_mapping_index'--sp
			, 'DB Error'--error type
			, 'Data Deleted Successfully.'
			, 'Data Deleted successfully.' --personal msg
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			, 'pratos_source_price_curve_map table'--tablename
			, 'spa_pratos_mapping_index'--sp
			, 'DB Error'--error type
			, 'The selected data cannot be deleted.'
			, 'Cannot Delete Data.' --personal msg 
			
		ROLLBACK 
	END CATCH
END 
