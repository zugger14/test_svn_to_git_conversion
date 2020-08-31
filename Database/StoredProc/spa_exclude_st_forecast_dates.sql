IF OBJECT_ID(N'[dbo].[spa_exclude_st_forecast_dates]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_exclude_st_forecast_dates
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rtuladhar@pioneersolutionsglobal.com
-- Create date: 2012-08-22
-- Description: CRUD operations for table exclude_st_forecast_dates
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- ===========================================================================================================
CREATE PROCEDURE [dbo].spa_exclude_st_forecast_dates
    @flag CHAR(1),
    @exclude_st_forecast_dates_id INT = NULL,
    @term_start DATETIME = NULL,
    @term_end DATETIME = NULL,
    @group_id INT = NULL,
    @date_from DATETIME = NULL,
    @date_to DATETIME = NULL
AS
 
DECLARE @SQL VARCHAR(MAX)
 
IF @flag = 's'
BEGIN
	SET @sql = 'SELECT exclude_st_forecast_dates_id AS [Exclude Short Forecast Dates ID], dbo.FNADateFormat(term_start) AS [Term Start], dbo.FNADateFormat(term_end) AS [Term End], sdv.code AS [Group] 
				FROM exclude_st_forecast_dates esfd
				INNER JOIN static_data_value sdv ON sdv.value_id = esfd.group_id
	            WHERE 1 = 1'
	            
	IF @date_from IS NOT NULL AND @date_to IS NULL
		SET @sql = @sql + ' AND term_start > ''' + CAST(@date_from AS VARCHAR(12)) + ''''
    
    IF @date_from IS NOT NULL AND @date_to IS NULL
		SET @sql = @sql + ' AND term_start < ''' + CAST(@date_to AS VARCHAR(12)) + ''''
    
    IF @date_from IS NOT NULL AND @date_to IS NOT NULL
		SET @sql = @sql + ' AND term_start BETWEEN ''' + CAST(@date_from AS VARCHAR(12)) + ''' AND ''' + + CAST(@date_to AS VARCHAR(12)) + ''''
    
    exec spa_print @sql
    EXEC(@sql)
END
ELSE IF @flag = 'a'
BEGIN
    SELECT dbo.FNADateFormat(term_start), dbo.FNADateFormat(term_end), group_id FROM exclude_st_forecast_dates
    WHERE [exclude_st_forecast_dates_id] = @exclude_st_forecast_dates_id
END
ELSE IF @flag = 'i'
BEGIN
    INSERT INTO exclude_st_forecast_dates(term_start, term_end, group_id)
    VALUES(@term_start, @term_end, @group_id)
    
	IF @@ERROR <> 0
		EXEC spa_ErrorHandler -1
			, 'exclude_st_forecast_dates'
			, 'spa_exclude_st_forecast_dates'
			, 'DB ERROR'
			, 'Error inserting Exclude Short Term Forecast Dates.'
			, ''
	ELSE				
		EXEC spa_ErrorHandler 0
			, 'exclude_st_forecast_dates'
			, 'spa_exclude_st_forecast_dates'
			, 'Success'
			, 'Exclude Short Term Forecast Dates successfully inserted.'
			, ''
    
END
ELSE IF @flag = 'u'
BEGIN
    UPDATE exclude_st_forecast_dates
    SET term_start = @term_start
		, term_end = @term_end
		, group_id = @group_id
    WHERE [exclude_st_forecast_dates_id] = @exclude_st_forecast_dates_id
    
    IF @@ERROR <> 0
		EXEC spa_ErrorHandler -1
			, 'exclude_st_forecast_dates'
			, 'spa_exclude_st_forecast_dates'
			, 'DB ERROR'
			, 'Error updating Exclude Short Term Forecast Dates.'
			, ''
	ELSE				
		EXEC spa_ErrorHandler 0
			, 'exclude_st_forecast_dates'
			, 'spa_exclude_st_forecast_dates'
			, 'Success'
			, 'Exclude Short Term Forecast Dates successfully updated.'
			, ''
END
ELSE IF @flag = 'd'
BEGIN
    DELETE FROM exclude_st_forecast_dates WHERE [exclude_st_forecast_dates_id] = @exclude_st_forecast_dates_id
    
    IF @@ERROR <> 0
		EXEC spa_ErrorHandler -1
			, 'exclude_st_forecast_dates'
			, 'spa_exclude_st_forecast_dates'
			, 'DB ERROR'
			, 'Error deleting Exclude Short Term Forecast Dates.'
			, ''
	ELSE				
		EXEC spa_ErrorHandler 0
			, 'exclude_st_forecast_dates'
			, 'spa_exclude_st_forecast_dates'
			, 'Success'
			, 'Exclude Short Term Forecast Dates successfully deleted.'
			, ''
END