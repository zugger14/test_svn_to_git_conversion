IF OBJECT_ID(N'[dbo].[spa_map_rate_schedules]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_map_rate_schedules]
GO

SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_map_rate_schedules]
	@flag CHAR(1),
	@location_loss_factor_id VARCHAR(MAX) = NULL
	
AS

SET NOCOUNT ON

DECLARE @DESC VARCHAR(500)
DECLARE @err_no INT 

IF @flag = 'g'
BEGIN
	SELECT	sdv.code [rate_schedule_type],
			llf.logical_name [logical_name],
			location_loss_factor_id [id],
			CASE WHEN rate_schedule_type = 39101 OR rate_schedule_type = 39102 THEN sml1.location_name ELSE sdv1.code END AS [from_location_zone],
			CASE WHEN rate_schedule_type = 39101 OR rate_schedule_type = 39103 THEN sml2.location_name ELSE sdv2.code END AS [to_location_zone],
			rate_schedule [rate_schedule]
	FROM location_loss_factor llf
	INNER JOIN static_data_value sdv ON llf.rate_schedule_type = sdv.value_id
	LEFT JOIN static_data_value sdv1 ON llf.from_zone = sdv1.value_id
	LEFT JOIN static_data_value sdv2 ON llf.to_zone = sdv2.value_id
	LEFT JOIN source_minor_location sml1 ON llf.from_location_id = sml1.source_minor_location_id
	LEFT JOIN source_minor_location sml2 ON llf.to_location_id = sml2.source_minor_location_id
END

ELSE IF @flag = 'r'
BEGIN
	SELECT value_id, code
	FROM static_data_value 
	WHERE [type_id] = 39100
END

ELSE IF @flag = 'l'
BEGIN
	EXEC spa_source_minor_location 'o'
END

ELSE IF @flag = 'z'
BEGIN
	SELECT value_id, code
	FROM static_data_value 
	WHERE [type_id] = 39200
END

ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			DELETE mrs
			FROM dbo.SplitCommaSeperatedValues(@location_loss_factor_id) i
			INNER JOIN map_rate_schedule mrs
				ON mrs.location_loss_factor_id = i.item

			DELETE llf
			FROM dbo.SplitCommaSeperatedValues(@location_loss_factor_id) i
			INNER JOIN location_loss_factor llf
				ON llf.location_loss_factor_id = i.item

			--SELECT * FROM map_rate_schedule
			--WHERE location_loss_factor_id IN (@location_loss_factor_id)

			--SELECT * FROM location_loss_factor
			--WHERE location_loss_factor_id IN (@location_loss_factor_id)
		
		COMMIT TRAN
		
		EXEC spa_ErrorHandler 0
					, 'location_loss_factor'
					, 'spa_map_rate_schedule'
					, 'Success' 
					, 'Changes have been saved successfully.'
					, @location_loss_factor_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
		
		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		SELECT @err_no = ERROR_NUMBER()

		EXEC spa_ErrorHandler @err_no
			, 'location_loss_factor'
			, 'spa_map_rate_schedule'
			, 'Error'
			, @DESC
			, ''
	END CATCH
END

ELSE IF @flag = 's'
BEGIN
	SELECT	map_rate_schedule_id,
			location_loss_factor_id,
			dbo.FNADateFormat(effective_date) [effective_date],
			fuel_loss,
			fuel_loss_group 
	FROM map_rate_schedule
	WHERE location_loss_factor_id = @location_loss_factor_id
END
