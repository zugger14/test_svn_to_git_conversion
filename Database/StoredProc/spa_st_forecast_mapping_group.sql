IF OBJECT_ID(N'[dbo].[spa_st_forecast_mapping_group]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_st_forecast_mapping_group]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: rtuladhar@pioneersolutionsglobal.com
-- Create date: 2012-02-29
-- Description: CRUD operations for table short_term_forecast_mapping

-- Params:
-- @flag CHAR(1) - Operation flag
-- @short_term_forecast_mapping_id INT 
-- @st_forecast_group_id INT = Group Id 
-- @location INT  - Location
-- @commodity_id INT - Commdity Id
-- @counterparty_id INT - Counterparty Id
-- @is_profiled CHAR - Is profile flag
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_st_forecast_mapping_group]
    @flag CHAR(1),
    @short_term_forecast_mapping_id INT = NULL,
    @location INT = NULL, 
    @commodity_id INT = NULL, 
    @counterparty_id INT = NULL,
    @is_profiled CHAR(1) = NULL,
    @st_forecast_group_header_id INT = NULL
AS

DECLARE @sql VARCHAR(MAX)

IF @flag = 's'
BEGIN
	SELECT	stfm.short_term_forecast_mapping_id AS [ST Forcast Mapping ID]
			, sdv.code AS [Group ID]
			, sml.Location_Name [Location]
			, sc.commodity_name [Commodity]	
			, counterparty.counterparty_name [Sales Channel]
			, + CASE WHEN IsProfiled = 'y' THEN 'Yes' WHEN IsProfiled = 'n' then 'No' ELSE '' END [Is Profiled]
	FROM short_term_forecast_mapping stfm
	INNER JOIN st_forecast_group_header sfgh ON sfgh.st_forecast_group_header_id = stfm.st_forecast_group_header_id
	INNER JOIN static_data_value sdv ON sdv.value_id = sfgh.st_forecast_group_id 
	LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = stfm.location
	LEFT JOIN source_commodity sc ON sc.source_commodity_id = stfm.commodity_id
	LEFT JOIN source_counterparty counterparty ON counterparty.source_counterparty_id = stfm.counterparty_id 
	WHERE stfm.st_forecast_group_header_id = @st_forecast_group_header_id
END
ELSE IF @flag = 'a'
BEGIN
    SELECT stfm.location, sml.Location_Name, stfm.commodity_id, stfm.counterparty_id, stfm.IsProfiled
    FROM short_term_forecast_mapping stfm
    LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = stfm.location
    WHERE short_term_forecast_mapping_id = @short_term_forecast_mapping_id
END
ELSE IF @flag = 'i'
BEGIN
    IF (@commodity_id <> '' AND @counterparty_id <> '')
    BEGIN
    	IF EXISTS (SELECT 1 FROM short_term_forecast_mapping WHERE commodity_id = @commodity_id 
    				AND counterparty_id = @counterparty_id 
    				AND IsProfiled = @is_profiled 
    				AND st_forecast_group_header_id = @st_forecast_group_header_id)
    	BEGIN
    		EXEC spa_ErrorHandler -1
				, 'Short Term Forcast Group'
				, 'spa_st_forecast_mapping_group'
				, 'DB ERROR'
				, 'Combination already exists.'
				, ''
			RETURN
    	END 
    END
    
    IF EXISTS (SELECT 1 FROM short_term_forecast_mapping stfm WHERE stfm.location = @location 
				AND stfm.st_forecast_group_header_id = @st_forecast_group_header_id)
	BEGIN
		EXEC spa_ErrorHandler -1
				, 'Short Term Forcast Group'
				, 'spa_st_forecast_mapping_group'
				, 'DB ERROR'
				, 'Location already in use.'
				, ''
			RETURN
	END
    
    INSERT INTO short_term_forecast_mapping (location, commodity_id, counterparty_id, IsProfiled, st_forecast_group_header_id)
    VALUES (@location, @commodity_id, @counterparty_id, @is_profiled, @st_forecast_group_header_id)
    
    IF @@ERROR <> 0
	EXEC spa_ErrorHandler -1
		, 'Short Term Forcast Group'
		, 'spa_st_forecast_mapping_group'
		, 'DB ERROR'
		, 'ERROR Inserting Short Term Forcast Group.'
		, ''
	ELSE
	EXEC spa_ErrorHandler 0
		, 'Short Term Forcast Group'
		, 'spa_st_forecast_mapping_group'
		, 'Success'
		, 'Short Term Forcast Group successfully inserted.'
		, ''
END
ELSE IF @flag = 'u'
BEGIN
    UPDATE	short_term_forecast_mapping
		SET	location = @location,
    		commodity_id = @commodity_id,
    		counterparty_id = @counterparty_id,
    		IsProfiled = @is_profiled
    WHERE short_term_forecast_mapping_id = @short_term_forecast_mapping_id
    
    IF @@ERROR <> 0
	EXEC spa_ErrorHandler -1
		, 'Short Term Forcast Group'
		, 'spa_st_forecast_mapping_group'
		, 'DB ERROR'
		, 'ERROR Updating Short Term Forcast Group.'
		, ''
	ELSE
	EXEC spa_ErrorHandler 0
		, 'Short Term Forcast Group'
		, 'spa_st_forecast_mapping_group'
		, 'Success'
		, 'Short Term Forcast Group successfully updated.'
		, ''
END
ELSE IF @flag = 'd'
BEGIN
    DELETE FROM short_term_forecast_mapping WHERE short_term_forecast_mapping_id = @short_term_forecast_mapping_id
    
    IF @@ERROR <> 0
	EXEC spa_ErrorHandler -1
		, 'Short Term Forcast Group'
		, 'spa_st_forecast_mapping_group'
		, 'DB ERROR'
		, 'ERROR Deleting Short Term Forcast Group.'
		, ''
	ELSE
	EXEC spa_ErrorHandler 0
		, 'Short Term Forcast Group'
		, 'spa_st_forecast_mapping_group'
		, 'Success'
		, 'Short Term Forcast Group successfully deleted.'
		, ''
END