IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_hourly_block]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_hourly_block]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_hourly_block]
	@flag CHAR(1),
	@code VARCHAR(200) = NULL,
	@block_value_id VARCHAR(200) = NULL,
	@holiday_value_id INT = NULL,
	@week_day INT = NULL,
	@onpeak_offpeak CHAR(1) = NULL,
	@hour_block VARCHAR(200) = NULL,
	@call_from VARCHAR(100) = NULL,
	@xml VARCHAR(MAX) = NULL

AS 
SET NOCOUNT ON

IF @flag = 's'
BEGIN
	SELECT block_value_id, week_day, onpeak_offpeak, holiday_value_id,
			hr1, hr2 ,hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10, hr11, hr12, hr13, hr14, hr15,
			hr16, hr17, hr18, hr19, hr20, hr21, hr22, hr23, hr24, s.code, s.[description], b.dst_applies 
	FROM hourly_block b 
	INNER JOIN static_data_value s ON b.block_value_id = s.value_id
	WHERE block_value_id = @block_value_id 
		AND onpeak_offpeak = 'p' 
	ORDER BY onpeak_offpeak, week_day
END

IF @flag = 't'
BEGIN
	SELECT week_day, onpeak_offpeak, holiday_value_id,from_month, to_month,
			hr1, hr2 ,hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10, hr11, hr12, hr13, hr14, hr15,
			hr16, hr17, hr18, hr19, hr20, hr21, hr22, hr23, hr24, b.dst_applies 
	FROM hourly_block b where block_value_id = @block_value_id
END

IF @flag = 'h'
BEGIN
	SELECT  onpeak_offpeak,
			hr1, hr2 ,hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10, hr11, hr12, hr13, hr14, hr15,
			hr16, hr17, hr18, hr19, hr20, hr21, hr22, hr23, hr24 
	FROM holiday_block b where block_value_id = @block_value_id
END

IF @flag ='d'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			IF @call_from = 'setup_static_data'
			BEGIN
				DECLARE @idoc INT
				EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
			
				IF OBJECT_ID('tempdb..#delete_static_data') IS NOT NULL
					DROP TABLE #delete_static_data
      
				SELECT grid_id
				INTO #delete_static_data
				FROM   OPENXML(@idoc, '/Root/GridGroup/GridDelete', 1) 
				WITH (
					grid_id INT
				)

				INSERT INTO hourly_block_sdv_audit (
					value_id,
					[TYPE_ID],
					code,
					[description],
					create_user,
					create_ts,
					update_user,
					update_ts,
					user_action
				)
				SELECT sdv.value_id,
					sdv.[type_id],
					sdv.code,
					sdv.[description],
					create_user,
					GETDATE(),
					dbo.FNADBUser(),
					GETDATE(),
					'Delete' [user_action]
				FROM static_data_value sdv
				INNER JOIN #delete_static_data dsd ON dsd.grid_id = sdv.value_id

				DELETE sdv
				FROM static_data_value sdv
				INNER JOIN #delete_static_data dsd ON dsd.grid_id = sdv.value_id
			END
			ELSE 
			BEGIN
				INSERT INTO hourly_block_sdv_audit (
					value_id,
					[TYPE_ID],
					code,
					[description],
					create_user,
					create_ts,
					update_user,
					update_ts,
					user_action
				)
				SELECT value_id,
					[type_id],
					code,
					[description],
					create_user,
					GETDATE(),
					dbo.FNADBUser(),
					GETDATE(),
					'Delete' [user_action]
				FROM static_data_value sdv
				INNER JOIN dbo.FNASplit(@block_value_id, ',') di ON di.item = sdv.value_id

				DELETE sdv
				FROM static_data_value sdv
				INNER JOIN dbo.FNASplit(@block_value_id, ',') di ON di.item = sdv.value_id
				--DELETE FROM holiday_block WHERE holiday_block_id = @block_value_id
				--DELETE FROM hourly_block WHERE block_value_id = @block_value_id
			END

		COMMIT TRAN

		EXEC spa_ErrorHandler 0
			, 'Hourly Block'
			, 'spa_hourly_block'
			, 'Success'
			, 'Changes have been saved Succesfully.'
			, @block_value_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK
		DECLARE @msg VARCHAR(500)		
		IF ERROR_NUMBER() = 547
			SELECT @msg = 'Data used in source price curve def.'
		ELSE
			SELECT @msg = 'Failed Detete record (' + ERROR_MESsAGE() + ').'
		EXEC spa_ErrorHandler -1
			, 'Hourly Block'
			, 'spa_'
			, 'spa_hourly_block'
			,  @msg
			, 'Failed Delete'
	END CATCH	
END

IF @flag = 'c'
BEGIN
	SELECT value_id, code from static_data_value where type_id = 10017 and category_id = 38700
END

GO