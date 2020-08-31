IF OBJECT_ID(N'[dbo].[spa_eligibility_mapping]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_eligibility_mapping]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rabhusal@pioneersolutionsglobal.com
-- Create date: 2018-07-12
-- Description: Selecting values from eligibility_mapping_template and eligibility_mapping_template_detail
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- @template_id INT - Template ID of the template created
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_eligibility_mapping]
    @flag			CHAR(1),
	@template_id	INT = NULL,
	@state_value_id	INT = NULL,
	@xml			VARCHAR(MAX) = NULL
AS

SET NOCOUNT ON

/*------- DEBUG ------
DECLARE @flag			CHAR(1),
	@template_id	INT = NULL,
	@state_value_id	INT = NULL,
	@xml			VARCHAR(MAX) = NULL

SELECT @flag = 'i' , @xml = '<Root object_id = "5"><FormGroup><Form template_id="5" template_name="Bauer Residence - Solar PV"></Form></FormGroup><GridGroup><GridDelete grid_id = "null" grid_label = "null"><GridRow  template_detail_id="10" template_id="5" state_value_id="50000612" tier_id="50000011" ></GridRow> </GridDelete><Grid grid_id="null"><GridRow  template_detail_id = "9" template_id = "5" state_value_id = "50000015" tier_id = "50000009" ></GridRow> <GridRow  template_id = "5" state_value_id = "50000612" tier_id = "50000011" ></GridRow> <GridRow  template_id = "5" state_value_id = "50000704" tier_id = "50000665" ></GridRow> </Grid></GridGroup></Root>'
--*/

DECLARE @sql VARCHAR(MAX),
	@xml_template_name VARCHAR(500) = NULL,
	@xml_template_id INT = NULL,
	@form_template_id VARCHAR(40) = NULL,
	@idoc INT = NULL


-- 's' flag used on to display template on Main Grid
IF @flag = 's'
BEGIN
	SELECT [template_id], [template_name]
	FROM eligibility_mapping_template
END
-- 'x' flag used to display template details on Eligibility Mapping Grid
ELSE IF @flag = 'x'
BEGIN
    SET @sql = '
		SELECT emtd.template_detail_id,
			emtd.template_id,
			emtd.state_value_id [jurisdiction],
			emtd.tier_id [tier]
		FROM eligibility_mapping_template_detail emtd
		INNER JOIN static_data_value sdv_jur ON sdv_jur.value_id = emtd.state_value_id AND sdv_jur.[type_id] = 10002
		INNER JOIN static_data_value sdv_tier ON sdv_tier.value_id = emtd.tier_id AND sdv_tier.[type_id] = 15000 '
		+ CASE WHEN @template_id IS NOT NULL THEN '	WHERE emtd.template_id = ' + CAST(@template_id AS VARCHAR(10)) + '' ELSE '' END + ''
	EXEC (@sql)
END
-- 'j' flag used to show combo values on Jurisdiction Column on Eligibility Mapping Grid
ELSE IF @flag = 'j'
BEGIN
    SELECT value_id AS id, code AS [value]
	FROM static_data_value
	WHERE [type_id] = 10002
END 
-- 't' flag used to show combo values on Tier Column on Eligibility Mapping Grid
ELSE IF @flag = 't'
BEGIN
    SELECT value_id AS id, code AS [value]
	FROM static_data_value
	WHERE [type_id] = 15000
END
-- 'l' flag used to load values in a dependent combo (tier)
ELSE IF @flag = 'l'
BEGIN
    SELECT sdv.value_id AS id, sdv.code AS [value]
	FROM static_data_value sdv
	INNER JOIN state_properties_details spd ON spd.tier_id = sdv.value_id
	WHERE sdv.[type_id] = 15000
		AND spd.state_value_id = @state_value_id
	GROUP BY sdv.value_id, sdv.code
END
-- 'i' flag used to insert/update/delete
ELSE IF @flag = 'i'
BEGIN
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

	IF OBJECT_ID('tempdb..#temp_eligibility_mapping_template_detail_iu') IS NOT NULL
		DROP TABLE #temp_eligibility_mapping_template_detail_iu

	IF OBJECT_ID('tempdb..#temp_eligibility_mapping_template_detail_del') IS NOT NULL
		DROP TABLE #temp_eligibility_mapping_template_detail_del

	SELECT	NULLIF(template_detail_id, '') [template_detail_id], 
			NULLIF(template_id, '') [template_id],
			NULLIF(state_value_id, '') [state_value_id],
			NULLIF(tier_id, '') [tier_id]
	INTO #temp_eligibility_mapping_template_detail_iu
	FROM OPENXML (@idoc, '/Root/GridGroup/Grid/GridRow', 2)
	WITH (
		template_detail_id INT '@template_detail_id',
		template_id INT '@template_id',
		state_value_id INT '@state_value_id',
		tier_id INT '@tier_id'
	)

	SELECT @xml_template_name = NULLIF(template_name, ''),
		@form_template_id = NULLIF(template_id, '')
	FROM OPENXML (@idoc, '/Root/FormGroup/Form', 2)
	WITH (
		template_name VARCHAR(500) '@template_name',
		template_id VARCHAR(40) '@template_id'
	)

	BEGIN TRY
	BEGIN TRAN
		IF NOT EXISTS (SELECT 1 FROM eligibility_mapping_template WHERE CAST(template_id AS VARCHAR(40)) = @form_template_id)
		BEGIN
			INSERT INTO eligibility_mapping_template (template_name) VALUES (@xml_template_name)
		END
		ELSE
		BEGIN
			UPDATE eligibility_mapping_template
			SET template_name = @xml_template_name
			WHERE template_id = @form_template_id
		END
	COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN

		DECLARE @err_msg1 VARCHAR(MAX)

		IF ERROR_NUMBER() = 2627
		BEGIN		
			SET @err_msg1 = 'Duplicate Data in <b>Template Name</b>.'
		END
		ELSE
			SET @err_msg1 = ERROR_MESSAGE()

		EXEC spa_ErrorHandler -1
			, 'eligibility_mapping_template_detail'
			, 'spa_eligibility_mapping'
			, 'Error' 
			, @err_msg1
			, @xml_template_id

		RETURN
	END CATCH

	BEGIN TRY
		BEGIN TRAN

		-- Update Case
		UPDATE emtd
		SET emtd.state_value_id = temtdi.state_value_id,
			emtd.tier_id = temtdi.tier_id
		FROM eligibility_mapping_template_detail emtd
		INNER JOIN #temp_eligibility_mapping_template_detail_iu temtdi
		ON temtdi.template_detail_id = emtd.template_detail_id
			AND temtdi.template_id = emtd.template_id

		-- Insert Case
		INSERT INTO eligibility_mapping_template_detail (template_id, state_value_id, tier_id)
		SELECT temtdi.template_id, temtdi.state_value_id, temtdi.tier_id 
		FROM #temp_eligibility_mapping_template_detail_iu temtdi
		INNER JOIN eligibility_mapping_template emt	ON emt.template_id = temtdi.template_id
		WHERE temtdi.template_detail_id IS NULL

		SELECT	NULLIF(template_detail_id, '') [template_detail_id], 
				NULLIF(template_id, '') [template_id],
				NULLIF(state_value_id, '') [state_value_id],
				NULLIF(tier_id, '') [tier_id]
		INTO #temp_eligibility_mapping_template_detail_del
		FROM OPENXML (@idoc, '/Root/GridGroup/GridDelete/GridRow', 2)
		WITH (
			template_detail_id INT '@template_detail_id',
			template_id INT '@template_id',
			state_value_id INT '@state_value_id',
			tier_id INT '@tier_id'
		) 

		DELETE emtd
		FROM #temp_eligibility_mapping_template_detail_del tempdd
		INNER JOIN eligibility_mapping_template emt	ON emt.template_id = tempdd.template_id
		INNER JOIN eligibility_mapping_template_detail emtd ON emtd.template_id = emt.template_id
			AND emtd.template_detail_id = tempdd.template_detail_id
		WHERE tempdd.template_detail_id IS NOT NULL

		COMMIT TRAN

		SELECT TOP 1 @xml_template_id = template_id FROM #temp_eligibility_mapping_template_detail_iu

		IF @xml_template_id IS NULL
		BEGIN
			SELECT TOP 1 @xml_template_id = template_id FROM eligibility_mapping_template WHERE template_name = @xml_template_name
		END

		EXEC spa_ErrorHandler 0
			, 'eligibility_mapping_template_detail'
			, 'spa_eligibility_mapping'
			, 'Success' 
			, 'Changes have been saved successfully.'
			, @xml_template_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN

		DECLARE @err_msg VARCHAR(MAX)

		IF ERROR_NUMBER() = 2627
		BEGIN		
			SET @err_msg = 'Duplicate Data in <b>(Jurisdiction and Tier)</b> in <b>Eligibility Mapping</b> grid.'
		END
		ELSE
			SET @err_msg = ERROR_MESSAGE()

		EXEC spa_ErrorHandler -1
			, 'eligibility_mapping_template_detail'
			, 'spa_eligibility_mapping'
			, 'Error' 
			, @err_msg
			, @xml_template_id
	END CATCH

END

GO