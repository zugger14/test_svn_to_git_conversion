IF OBJECT_ID(N'[dbo].[spa_st_forecast_group_header]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_st_forecast_group_header
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: rtuladhar@pioneersolutionsglobal.com
-- Create date: 2011-06-06
-- Description: CRUD operations for table spa_st_forecast_group_header

-- Params:
-- @flag CHAR(1) - Operation flag
-- ===========================================================================================================

CREATE PROCEDURE [dbo].spa_st_forecast_group_header
    @flag CHAR(1),
	@st_forecast_group_header_id INT = NULL,
	@st_forecast_group_id INT = NULL,
	@uom_id INT = NULL,
	@granularity_id INT = NULL,
	@multiplier INT = NULL
AS

DECLARE @sql VARCHAR(MAX)

IF @flag = 's'
BEGIN
	SELECT	st_forecast_group_header_id [ST Forecast Group Header ID]
			, group_name.code [Group Name]
			, su.uom_name [UOM]
			, granularity.code [Granularity]
			, multiplier [Multiplier] 
	FROM st_forecast_group_header sfgh
	INNER JOIN static_data_value group_name ON group_name.value_id = sfgh.st_forecast_group_id
	INNER JOIN source_uom su ON su.source_uom_id = sfgh.uom_id
	INNER JOIN static_data_value granularity ON granularity.value_id = sfgh.granularity_id
END
ELSE IF @flag = 'a'
BEGIN
	SELECT * FROM st_forecast_group_header sfgh WHERE sfgh.st_forecast_group_header_id = @st_forecast_group_header_id
END
ELSE IF @flag = 'i'
BEGIN
	IF EXISTS (SELECT 1 FROM st_forecast_group_header sfgh WHERE sfgh.uom_id = @uom_id
				AND sfgh.granularity_id = @granularity_id AND sfgh.multiplier = @multiplier)
	BEGIN
		EXEC spa_ErrorHandler -1
			, 'Short Term Forcast Group'
			, 'spa_st_forecast_group_header'
			, 'DB ERROR'
			, 'Short Term Forcast Combination already exists.'
			, ''
		
		RETURN
	END
	
	IF EXISTS (SELECT 1 FROM st_forecast_group_header sfgh WHERE sfgh.st_forecast_group_id = @st_forecast_group_id)
	BEGIN
		EXEC spa_ErrorHandler -1
			, 'Short Term Forcast Group'
			, 'spa_st_forecast_group_header'
			, 'DB ERROR'
			, 'Short Term Forcast Group already exists.'
			, ''
	END
	ELSE 
	BEGIN
		INSERT INTO st_forecast_group_header (st_forecast_group_id
											, uom_id
											, granularity_id
											, multiplier)
		VALUES (@st_forecast_group_id, @uom_id, @granularity_id, @multiplier) 
		
		IF @@ERROR <> 0
			EXEC spa_ErrorHandler -1
				, 'Short Term Forcast Group'
				, 'spa_st_forecast_group_header'
				, 'DB ERROR'
				, 'ERROR Inserting Short Term Forcast Group.'
				, ''
		ELSE
			EXEC spa_ErrorHandler 0
				, 'Short Term Forcast Group'
				, 'spa_st_forecast_group_header'
				, 'Success'
				, 'Short Term Forcast Group successfully inserted.'
				, ''
	END
END
ELSE IF @flag = 'u'
BEGIN
	IF EXISTS (SELECT 1 FROM st_forecast_group_header sfgh WHERE sfgh.uom_id = @uom_id
				AND sfgh.granularity_id = @granularity_id AND sfgh.multiplier = @multiplier
				AND @st_forecast_group_header_id <> @st_forecast_group_header_id)
	BEGIN
		EXEC spa_ErrorHandler -1
			, 'Short Term Forcast Group'
			, 'spa_st_forecast_group_header'
			, 'DB ERROR'
			, 'Short Term Forcast Combination already exists.'
			, ''
		RETURN
	END
	IF EXISTS(SELECT 1 FROM st_forecast_group_header sfgh 
	          WHERE sfgh.st_forecast_group_id = @st_forecast_group_id
					AND sfgh.st_forecast_group_header_id <> @st_forecast_group_header_id)
	BEGIN
		EXEC spa_ErrorHandler -1
			, 'Short Term Forcast Group'
			, 'spa_st_forecast_group_header'
			, 'DB ERROR'
			, 'Short Term Forcast Group already exists.'
			, ''
	END
	ELSE
	BEGIN
		UPDATE	st_forecast_group_header 
			SET st_forecast_group_id =  @st_forecast_group_id
				, uom_id = @uom_id
				, granularity_id = @granularity_id
				, multiplier = @multiplier
		WHERE st_forecast_group_header_id = @st_forecast_group_header_id
		
		IF @@ERROR <> 0
			EXEC spa_ErrorHandler -1
				, 'Short Term Forcast Group'
				, 'spa_st_forecast_group_header'
				, 'DB ERROR'
				, 'ERROR Updateing Short Term Forcast Group.'
				, ''
		ELSE
			EXEC spa_ErrorHandler 0
				, 'Short Term Forcast Group'
				, 'spa_st_forecast_group_header'
				, 'Success'
				, 'Short Term Forcast Group successfully updated.'
				, @st_forecast_group_header_id	
	END
END
ELSE IF @flag = 'd'
BEGIN
	DELETE FROM short_term_forecast_mapping WHERE st_forecast_group_header_id = @st_forecast_group_header_id
	DELETE FROM st_forecast_group_header WHERE st_forecast_group_header_id = @st_forecast_group_header_id
	IF @@ERROR <> 0
		EXEC spa_ErrorHandler -1
			, 'Short Term Forcast Group'
			, 'spa_st_forecast_group_header'
			, 'DB ERROR'
			, 'ERROR Deleting Short Term Forcast Group.'
			, ''
	ELSE
		EXEC spa_ErrorHandler 0
			, 'Short Term Forcast Group'
			, 'spa_st_forecast_group_header'
			, 'Success'
			, 'Short Term Forcast Group successfully deleted.'
			, @st_forecast_group_header_id
END