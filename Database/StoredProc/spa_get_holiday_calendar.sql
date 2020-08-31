IF OBJECT_ID(N'[dbo].[spa_get_holiday_calendar]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_get_holiday_calendar]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2012-07-30
-- Description: Get holiday calendar.
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_get_holiday_calendar]
    @flag CHAR(1), 
	@value_id VARCHAR(1000) = NULL,
	@xml VARCHAR(MAX) = NULL
AS
SET NOCOUNT ON

IF @flag = 's'
BEGIN
	SELECT sdv.type_id,
	       sdv.value_id,
	       sdv.code AS Code,
	       sdv.[description] DESCRIPTION
	FROM   static_data_value sdv
	WHERE sdv.category_id = 38700	
	ORDER BY code
END

IF @flag = 'g'
BEGIN
	SELECT hol_group_ID AS [ID],
		hol_group_value_id AS [Value ID],
		dbo.FNADateFormat(hg.hol_date) AS [Date From],
		dbo.FNADateFormat(hg.hol_date_to) AS [Date to],
		dbo.FNADateFormat(hg.exp_date) AS [Expiration Date], 
		dbo.FNADateFormat(hg.settlement_date) AS [Settlement Date],
		hg.[description] AS [Description]
	FROM holiday_group hg
	INNER JOIN dbo.FNASplit(@value_id, ',') it ON it.item = hg.hol_group_value_id
END

IF @flag = 'd'
BEGIN
	BEGIN TRY
		DELETE hg
		FROM holiday_group hg
		INNER JOIN dbo.FNASplit(@value_id, ',') it ON it.item = hg.hol_group_ID

		EXEC spa_ErrorHandler 0, 
			'Holiday Calendar', 
			'spa_get_holiday_calendar', 
			'Success', 
			'Changes have been saved successfully.',
			''
	END TRY
	BEGIN CATCH
		DECLARE @msg VARCHAR(5000)
		SELECT @msg = 'Failed Inserting record (' + ERROR_MESSAGE() + ').'

		EXEC spa_ErrorHandler -1, 
			'holiday calendar', 
			'spa_get_holiday_calendar', 
			'Error', 
			@msg, 
			''
		RETURN
	END CATCH
END
IF @flag ='e'
BEGIN
	BEGIN TRAN
	BEGIN TRY
		DECLARE @idoc INT
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
			
		IF OBJECT_ID('tempdb..#delete_static_data') IS NOT NULL
			DROP TABLE #delete_static_data
      
		SELECT grid_id
		INTO #delete_static_data
		FROM OPENXML(@idoc, '/Root/GridGroup/GridDelete', 1)
		WITH (grid_id INT)
		
		DELETE sdv
		FROM static_data_value sdv
		INNER JOIN #delete_static_data dsd ON dsd.grid_id = sdv.value_id
				
		COMMIT TRAN
		EXEC spa_ErrorHandler 0
			, 'Calendar'
			, 'spa_get_holiday_calendar'
			, 'Success'
			, 'Changes have been saved successfully.'
			, 'value_id'
		END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK
		
		SELECT @msg = 'Failed to delete record (' + ERROR_MESSAGE() + ').'
	
		EXEC spa_ErrorHandler -1
			, 'Calendar'
			, 'spa_'
			, 'spa_get_holiday_calendar'
			, @msg
			, 'Failed Delete'
	END CATCH	
END

IF @flag = 'a'
BEGIN
	SELECT ec.expiration_calendar_id,
		sdv.code AS calendar,
		sdv1.code AS holiday_calendar,
		dbo.FNADateFormat(ec.delivery_period) delivery_period,
		dbo.FNADateFormat(ec.expiration_from) expiration_from,
		dbo.FNADateFormat(ec.expiration_to) expiration_to
	FROM expiration_calendar ec
	LEFT JOIN static_data_value sdv ON sdv.value_id = ec.calendar_id
	LEFT JOIN static_data_value sdv1 ON sdv1.value_id = ec.holiday_calendar
	INNER JOIN dbo.FNASplit(@value_id, ',') it ON it.item = ec.calendar_id
END

IF @flag = 'b'
BEGIN
	SELECT value_id, code
	FROM static_data_value
	WHERE category_id = 38700
END

IF @flag = 'c'
BEGIN
	SELECT MAX(ec.holiday_calendar) holiday_calendar
	FROM expiration_calendar ec
	INNER JOIN dbo.FNASplit(@value_id, ',') it ON it.item = ec.calendar_id
END

--EXEC spa_get_holiday_calendar 'c', 403239

GO