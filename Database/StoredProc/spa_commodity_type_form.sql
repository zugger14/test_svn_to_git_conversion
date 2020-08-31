IF OBJECT_ID('dbo.spa_commodity_type_form') IS NOT NULL
	DROP PROCEDURE dbo.spa_commodity_type_form
GO

CREATE PROCEDURE dbo.spa_commodity_type_form
	@flag CHAR(1)
  	, @commodity_type_id VARCHAR(1000)
  	, @xml VARCHAR(MAX) = NULL
  	, @call_from VARCHAR(MAX) = NULL
AS

SET NOCOUNT ON

IF @flag = 's'
BEGIN
	SELECT commodity_type_form_id, 
		   commodity_type_id,
		   commodity_form_value
	FROM  commodity_type_form ctf
	INNER JOIN dbo.FNASplit(@commodity_type_id, ',') di ON di.item = ctf.commodity_type_id
END
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			IF @call_from = 'setup_static_data'
			BEGIN
				DECLARE @idoc INT
				EXEC sp_xml_preparedocument @idoc OUTPUT,
					 @xml
			
				IF OBJECT_ID('tempdb..#delete_static_data') IS NOT NULL
					DROP TABLE #delete_static_data
      
				SELECT grid_id
				INTO #delete_static_data
				FROM   OPENXML(@idoc, '/Root/GridGroup/GridDelete', 1) 
				WITH (
					grid_id INT
				)
		
				DELETE ctf
				FROM commodity_type_form ctf
				INNER JOIN #delete_static_data dsd ON dsd.grid_id = ctf.commodity_type_id
		
				DELETE ct 
				FROM commodity_type ct 
				INNER JOIN #delete_static_data dsd ON dsd.grid_id = ct.commodity_type_id
			END
			ELSE
			BEGIN
				DELETE ctf
				FROM commodity_type_form ctf
				INNER JOIN dbo.FNASplit(@commodity_type_id, ',') di ON di.item = ctf.commodity_type_id

				DELETE ct
				FROM commodity_type ct
				INNER JOIN dbo.FNASplit(@commodity_type_id, ',') di ON di.item = ct.commodity_type_id
			END

		COMMIT TRAN

		EXEC spa_ErrorHandler 0
			, 'Commodity Type'
			, 'spa_commodity_type_form'
			, 'Success'
			, 'Changes have been saved Succesfully..'
			, ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN

		DECLARE @err_msg VARCHAR(MAX) = ERROR_MESSAGE()

		EXEC spa_ErrorHandler -1
			, 'Commodity Type'
			, 'spa_commodity_type_form'
			, 'Error'
			, @err_msg
			, ''
	END CATCH
END

GO