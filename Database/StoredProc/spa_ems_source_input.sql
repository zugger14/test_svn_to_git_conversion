IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_ems_source_input]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_ems_source_input]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[spa_ems_source_input]
	@flag CHAR(1),
	@ems_source_input_id INT = NULL,
	@input_name VARCHAR(100) = NULL,
	@uom_id INT = NULL,
	@char_applies char(1) = NULL,
	@input_output_id VARCHAR(100) = NULL,
	@constant_value VARCHAR(1) = NULL,
	@heatcontent_uom_id INT = NULL,
	@generator_id INT = NULL,
	@ems_source_model_id VARCHAR(500) = NULL,
	@rec_generator_id INT = NULL,
	@max_value FLOAT = NULL,
	@min_value FLOAT = NULL,
	@rating_value_id INT = NULL

AS

SET NOCOUNT ON

BEGIN

DECLARE @sql varchar(8000)
DECLARE @charApplies CHAR(1)
--ems_input_valid_values eivv

IF @flag = 's'
BEGIN
	SET @sql='
	SELECT ems.ems_source_input_id [ID],
		input_name [Input Type],
		char_applies [Char Applies],
		su.uom_name UOM,    
		sdv.code [Input/Output],
		eivv.min_value [Minimum Value],	
		eivv.max_value [Maximum Value],
		ems.uom_id [UOM ID],
		constant_value Constant,
		sdv1.code [Rating]
	FROM ems_source_input ems
	LEFT JOIN source_uom su on su.source_uom_id = ems.uom_id
	LEFT JOIN ems_input_valid_values eivv on eivv.ems_source_input_id = ems.ems_source_input_id
	LEFT JOIN static_data_value sdv on sdv.value_id = ems.input_output_id
	LEFT JOIN static_data_value sdv1 on sdv1.value_id = ems.rating_value_id
	' + 
	CASE WHEN @generator_id IS NOT NULL THEN '
	LEFT JOIN ems_input_map map ON ems.ems_source_input_id = map.input_id
	LEFT JOIN ems_source_model_effective esme ON esme.ems_source_model_id = map.source_model_id
	INNER JOIN (
		SELECT MAX(ISNULL(effective_date,''1900-01-01'')) effective_date, generator_id
		FROM ems_source_model_effective WHERE 1 = 1 GROUP BY generator_id) ab
	ON esme.generator_id = ab.generator_id AND ISNULL(esme.effective_date, ''1900-01-01'') = ab.effective_date
	LEFT JOIN rec_generator rec ON ab.generator_id = rec.generator_id
	WHERE rec.generator_id = ' + CAST(@generator_id AS VARCHAR)

	WHEN @ems_source_model_id IS NOT NULL THEN '
	LEFT JOIN ems_input_map map ON ems.ems_source_input_id = map.input_id
	WHERE map.source_model_id IN(' + CAST(@ems_source_model_id AS VARCHAR) + ')'
	ELSE '
	WHERE 1 = 1 '
	END

	IF @ems_source_input_id IS NOT NULL
		SET @sql=@sql +' AND ems.ems_source_input_id = ' + CAST(@ems_source_input_id AS VARCHAR)
	IF @input_output_id IS NOT NULL
		SET @sql=@sql +' AND input_output_id IN('+ CAST(@input_output_id AS VARCHAR) +')'
	SET @sql=@sql +' ORDER BY input_name'
	
	EXEC(@sql)
END

ELSE IF @flag = 's'
BEGIN
	SET @sql = '
	SELECT ems.ems_source_input_id [ID],
		dbo.FNAEmissionHyperlink(2, 12101300, input_name, ems.ems_source_input_id, NULL) [InputType],
		char_applies [CharApplies],
		su.uom_name UOM,    
		sdv.code [Input/Output],
		eivv.max_value [Maximum Value],
		eivv.min_value [Minimum Value],
		ems.uom_id [UOMID],
		constant_value Constant,
		sdv1.code as Rating
	FROM ems_source_input ems
	LEFT JOIN source_uom su ON su.source_uom_id = ems.uom_id
	LEFT JOIN ems_input_valid_values eivv ON eivv.ems_source_input_id = ems.ems_source_input_id
	LEFT JOIN static_data_value sdv ON sdv.value_id = ems.input_output_id
	LEFT JOIN static_data_value sdv1 ON sdv1.value_id = ems.rating_value_id
	' +
	CASE WHEN @ems_source_model_id IS NOT NULL THEN '
	LEFT JOIN ems_input_map map ON ems.ems_source_input_id = map.input_id
	WHERE map.source_model_id = ' + CAST(@ems_source_model_id AS VARCHAR)
	ELSE '
	WHERE 1 = 1'
	END

	IF @ems_source_input_id IS NOT NULL
		SET @sql = @sql + ' AND ems.ems_source_input_id = '+ CAST(@ems_source_input_id AS VARCHAR)
	IF @input_output_id IS NOT NULL
		SET @sql = @sql + ' AND input_output_id IN(' + CAST(@input_output_id AS VARCHAR) + ')'
	SET @sql = @sql + ' ORDER BY input_name'
	
	EXEC(@sql)
END

ELSE IF @flag = 'e' --List by SourceID
BEGIN
	SELECT ems_source_input_id [ID],
		input_name [InputType]
	FROM ems_source_input ems
	WHERE input_output_id = @input_output_id
	ORDER BY input_name
END

ELSE IF @flag = 'a'
BEGIN
	SELECT ems.ems_source_input_id,
		ems.input_name,
		ems.char_applies,
		ems.uom_id,
		ems.input_output_id,
		ems.constant_value,
		ems.heatcontent_uom_id,
		eivv.rec_generator_id,
		eivv.max_value,
		eivv.min_value,
		ems.rating_value_id
	FROM ems_source_input ems
	LEFT JOIN ems_input_valid_values eivv ON eivv.ems_source_input_id = ems.ems_source_input_id
	WHERE ems.ems_source_input_id = @ems_source_input_id
END

ELSE IF @flag='i'
BEGIN
	BEGIN TRAN
	DECLARE @temp_ems_source_input_id INT
	IF EXISTS(SELECT input_name FROM ems_source_input WHERE input_name = @input_name)
	BEGIN
		EXEC spa_ErrorHandler -1, 'Failed to insert values: Cannot insert Duplicate Input Type',
			'spa_ems_source_input', 'DB Error', 
			'Failed to insert values: Cannot insert Duplicate Input Type.', ''
		RETURN
	END

	INSERT INTO ems_source_input(
		input_name,
		uom_id,
		char_applies,
		input_output_id,
		constant_value,
		heatcontent_uom_id,
		rating_value_id
	)
	SELECT @input_name,
		@uom_id,
		@char_applies,
		@input_output_id,
		@constant_value,
		@heatcontent_uom_id,
		@rating_value_id

	SET	@temp_ems_source_input_id = SCOPE_IDENTITY()
	IF @@ERROR <> 0
	BEGIN
		EXEC spa_ErrorHandler @@ERROR, 'Ems Source Inputs',
			'spa_ems_source_model', 'DB Error', 
			'Error Inserting Ems Source Model Inputs.', ''
		ROLLBACK TRAN
	END
	ELSE
	BEGIN
		INSERT INTO ems_input_valid_values(
			ems_source_input_id,
			rec_generator_id,
			max_value,
			min_value
		)
		SELECT @temp_ems_source_input_id,
			@rec_generator_id,
			@max_value,
			@min_value

		If @@ERROR <> 0
			EXEC spa_ErrorHandler @@ERROR, 'Failed to insert values', 
				'spa_ems_source_input', 'DB Error', 
				'Failed to insert values.', ''
		ELSE
			EXEC spa_ErrorHandler 0, 'Successfully insert values', 
				'spa_ems_source_input', 'Success', 
				'Successfully insert values.',''
				
		COMMIT TRAN
	END
END

ELSE IF @flag='u'
BEGIN
	BEGIN
		IF EXISTS(SELECT input_name FROM ems_source_input WHERE input_name = @input_name AND ems_source_input_id <> @ems_source_input_id)
		BEGIN
			EXEC spa_ErrorHandler -1, 'Failed to insert values: Cannot insert Duplicate Input Type', 
				'spa_ems_source_input', 'DB Error', 
				'Failed to insert values: Cannot insert Duplicate Input Type.', ''
			RETURN
		END

		UPDATE ems_source_input
		SET	uom_id=@uom_id,
			input_name=@input_name,
			char_applies=@char_applies,
			input_output_id=@input_output_id,
			constant_value=@constant_value,
			heatcontent_uom_id=@heatcontent_uom_id,
			rating_value_id=@rating_value_id
		WHERE ems_source_input_id = @ems_source_input_id

		IF @@ERROR <> 0
			EXEC spa_ErrorHandler @@ERROR, 'Failed to insert values.',
				'spa_ems_source_model', 'DB Error',
				'Error Updating Ems Source Model Inputs.', ''
		ELSE
			EXEC spa_ErrorHandler 0, 'Successfully insert values.',
				'spa_ems_source_model', 'Success', 
				'Successfully insert values.', ''
	END
	BEGIN
		DECLARE @tmp_ems_source_input_id INT
			
		 SELECT @tmp_ems_source_input_id = ems_source_input_id FROM ems_input_valid_values WHERE ems_source_input_id = @ems_source_input_id 
		
		IF @tmp_ems_source_input_id IS NULL
		BEGIN
			INSERT INTO ems_input_valid_values(
				ems_source_input_id,
				rec_generator_id,
				max_value,
				min_value
			)
			SELECT @ems_source_input_id,
				@rec_generator_id,
				@max_value,
				@min_value
			
			IF @@ERROR <> 0
				EXEC spa_ErrorHandler @@ERROR, 'ems_input_valid_values', 
				'spa_ems_source_input', 'DB Error', 
				'Error Copying ems_input_valid_values.', ''
			ELSE
				EXEC spa_ErrorHandler 0, 'ems_input_valid_values', 
				'spa_ems_source_input', 'Success', 
				'spa_ems_source_input successfully Copied.',''
		END
		ELSE
		BEGIN
			UPDATE ems_input_valid_values
			SET rec_generator_id = @rec_generator_id,
				max_value = @max_value,
				min_value = @min_value
			WHERE ems_source_input_id = @ems_source_input_id

			IF @@ERROR <> 0
				EXEC spa_ErrorHandler @@ERROR, 'ems_input_valid_values', 
				'spa_ems_source_input', 'DB Error', 
				'Error updating ems_input_valid_values.', ''
			ELSE
				EXEC spa_ErrorHandler 0, 'ems_input_valid_values', 
				'spa_ems_source_input', 'Success', 
				'Ems input valid values successfully Updated.', ''
		END
	END
END

ELSE IF @flag='d'
--BEGIN TRAN
--	delete from ems_source_input 
--		where ems_source_input_id=@ems_source_input_id
--
--	If @@ERROR <> 0
--		BEGIN
--			Exec spa_ErrorHandler @@ERROR, "Ems Source Model", 
--			"spa_ems_source_model", "DB Error", 
--			"Error Deleting Ems Source Model Inputs.", ''
--		ROLLBACK TRAN
--		END
--	else
--		BEGIN
--			delete from ems_input_valid_values
--				where ems_source_input_id=@ems_source_input_id
--			
--			If @@ERROR <> 0
--					Exec spa_ErrorHandler @@ERROR, 'ems_input_valid_values', 
--					'spa_ems_source_input', 'DB Error', 
--					'Error Deleting ems_input_valid_values.', ''
--				else
--					Exec spa_ErrorHandler 0, 'ems_input_valid_values', 
--					'spa_ems_source_input', 'Success', 
--					'Ems input valid values successfully Deleted.',''
--		
--		COMMIT TRAN
--		END	
----		Exec spa_ErrorHandler 0, 'Ems Source Model', 
----		'spa_meter', 'Success', 
----		'Ems Source Model Inputs successfully Deleted.',''
--END
--
--END

--ems_source_conversion
BEGIN
	SELECT @charApplies = char_applies FROM ems_source_input WHERE ems_source_input_id = @ems_source_input_id
	
	IF @charApplies = 'y'
	BEGIN
		IF EXISTS (SELECT 'X' FROM ems_input_characteristics WHERE ems_source_input_id = @ems_source_input_id) GOTO propertyError 
		BEGIN
			IF EXISTS (SELECT 'X' FROM ems_conversion_type WHERE ems_source_input_id = @ems_source_input_id) GOTO propertyError
			BEGIN
				IF EXISTS (SELECT 'X' FROM ems_source_conversion WHERE ems_source_input_id = @ems_source_input_id) GOTO conversionError
				BEGIN
					DELETE FROM ems_source_input 
					WHERE ems_source_input_id=@ems_source_input_id
						
					DELETE FROM ems_input_valid_values
					WHERE ems_source_input_id=@ems_source_input_id

					EXEC spa_ErrorHandler 0, 'ems_input_valid_values', 
						'spa_ems_source_input', 'Success', 
						'Ems input valid values successfully Deleted.', ''
				END						
			END
		END
	END
	ELSE IF @charApplies IS NULL
	BEGIN
		IF EXISTS (SELECT 'X' FROM ems_source_conversion WHERE ems_source_input_id = @ems_source_input_id) GOTO conversionError
		BEGIN
			DELETE FROM ems_source_input 
			WHERE ems_source_input_id=@ems_source_input_id
				
			DELETE FROM ems_input_valid_values
			WHERE ems_source_input_id=@ems_source_input_id
		
			EXEC spa_ErrorHandler 0, 'ems_input_valid_values', 
				'spa_ems_source_input', 'Success', 
				'Ems input valid values successfully Deleted.', ''
		END
	END
	
	propertyError:
	BEGIN
		EXEC spa_ErrorHandler -1, 'Please delete Properties first.', 
		'spa_ems_source_model', 'DB Error', 
		'Please delete Properties first.', ''
		RETURN
	END
				
	conversionError: 
	BEGIN
		EXEC spa_ErrorHandler -1, 'Please delete Emission Conversion Factor first.', 
		'spa_ems_source_model', 'DB Error', 
		'Please delete Emission Conversion Factor first.', ''
		RETURN
	END

	END	

END

GO