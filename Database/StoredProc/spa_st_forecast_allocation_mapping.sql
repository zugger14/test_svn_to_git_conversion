IF OBJECT_ID(N'[dbo].[spa_st_forecast_allocation_mapping]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_st_forecast_allocation_mapping
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: rtuladhar@pioneersolutionsglobal.com
-- Create date: 2012-02-29
-- Description: CRUD operations for table short_term_forecast_allocation

-- Params:
-- @flag CHAR(1) - Operation flag
-- @short_term_forecast_allocation_id INT = NULL = Allocation id
-- @st_forecast_group_id INT = NULL - group id
-- @source_deal_header_id INT = NULL - deal id
-- @percentage_allocation FLOAT = NULL - allocated percentage
-- ===========================================================================================================
CREATE PROCEDURE [dbo].spa_st_forecast_allocation_mapping
    @flag CHAR(1),
    @short_term_forecast_allocation_id INT = NULL,
    @st_forecast_group_id INT = NULL,
	@source_deal_header_id INT = NULL,
	@percentage_allocation FLOAT = NULL
AS

DECLARE @sql VARCHAR(MAX)

IF @flag = 's'
BEGIN
   SELECT	short_term_forecast_allocation_id AS [ST Forecast Allocation ID]
			, sdv.code AS [Group]
			, stfa.source_deal_header_id [Deal ID]
			, sdh.deal_id [Reference ID]
			, percentage_allocation [Allocation Percentage]
   FROM short_term_forecast_allocation stfa
   INNER JOIN static_data_value sdv ON sdv.value_id = stfa.st_forecast_group_id
   INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = stfa.source_deal_header_id
END
ELSE IF @flag = 'a'
BEGIN
    SELECT stfa.st_forecast_group_id, stfa.source_deal_header_id, sdh.deal_id, stfa.percentage_allocation
	FROM short_term_forecast_allocation stfa 
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = stfa.source_deal_header_id
	WHERE short_term_forecast_allocation_id = @short_term_forecast_allocation_id
END
ELSE IF @flag = 'i'
BEGIN
	INSERT INTO short_term_forecast_allocation(st_forecast_group_id, source_deal_header_id, percentage_allocation)
	VALUES (@st_forecast_group_id, @source_deal_header_id, @percentage_allocation)
	
	IF @@ERROR <> 0
	EXEC spa_ErrorHandler -1
		, 'Short Term Forcast Allocation'
		, 'spa_st_forecast_allocation_mapping'
		, 'DB ERROR'
		, 'ERROR Inserting Short Term Forcast Allocation.'
		, ''
	ELSE
	EXEC spa_ErrorHandler 0
		, 'Short Term Forcast Allocation'
		, 'spa_st_forecast_allocation_mapping'
		, 'Success'
		, 'Short Term Forcast Allocation successfully inserted.'
		, ''
END
ELSE IF @flag = 'u'
BEGIN
   UPDATE	short_term_forecast_allocation
	   SET	st_forecast_group_id = @st_forecast_group_id,
   			source_deal_header_id = @source_deal_header_id,
   			percentage_allocation = @percentage_allocation
   WHERE short_term_forecast_allocation_id = @short_term_forecast_allocation_id
   
   IF @@ERROR <> 0
	EXEC spa_ErrorHandler -1
		, 'Short Term Forcast Allocation'
		, 'spa_st_forecast_allocation_mapping'
		, 'DB ERROR'
		, 'ERROR Updating Short Term Forcast Allocation.'
		, ''
	ELSE
	EXEC spa_ErrorHandler 0
		, 'Short Term Forcast Allocation'
		, 'spa_st_forecast_allocation_mapping'
		, 'Success'
		, 'Short Term Forcast Allocation successfully updated.'
		, ''
END
ELSE IF @flag = 'd'
BEGIN
    DELETE FROM short_term_forecast_allocation WHERE short_term_forecast_allocation_id = @short_term_forecast_allocation_id
    
    IF @@ERROR <> 0
	EXEC spa_ErrorHandler -1
		, 'Short Term Forcast Allocation'
		, 'spa_st_forecast_allocation_mapping'
		, 'DB ERROR'
		, 'ERROR Deleting Short Term Forcast Allocation.'
		, ''
	ELSE
	EXEC spa_ErrorHandler 0
		, 'Short Term Forcast Allocation'
		, 'spa_st_forecast_allocation_mapping'
		, 'Success'
		, 'Short Term Forcast Allocation successfully deleted.'
		, ''
END