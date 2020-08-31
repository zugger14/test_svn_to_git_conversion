IF OBJECT_ID(N'[dbo].[spa_ems_input_characteristics]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_ems_input_characteristics]
GO

-- EXEC spa_ems_input_characteristics 'a',NULL,NULL,47,NULL
CREATE PROCEDURE [dbo].[spa_ems_input_characteristics]
	@flag AS CHAR(1),
	@type_char_id INT = NULL,
	@type_id INT = NULL,
	@ems_source_input_id INT = NULL,
	@ems_conversion_type_value_id INT = NULL
AS

SET NOCOUNT ON

DECLARE @sequence_id INT
DECLARE @errorCode INT

IF @flag = 's'
BEGIN
	SELECT ic.type_char_id,
		t.Code,
		t.[Description]
	FROM ems_input_characteristics ic
	INNER JOIN ems_static_data_type t ON t.[type_id] = ic.[type_id]
	INNER JOIN ems_conversion_type ct ON ic.type_char_id = ct.type_char_id
	WHERE ic.ems_source_input_id = @ems_source_input_id
		AND ct.ems_conversion_type_value_id = @ems_conversion_type_value_id
END

ELSE IF @flag = 't' --Select Char. which is not include already
BEGIN
	SELECT [type_id] ID,
		Code,
		[Description]
	FROM ems_static_data_type
	WHERE [type_id] NOT IN (
		SELECT [type_id] FROM ems_input_characteristics ic
		INNER JOIN ems_conversion_type ct ON ic.type_char_id = ct.type_char_id
		WHERE ic.ems_source_input_id = @ems_source_input_id
			AND ct.ems_conversion_type_value_id = @ems_conversion_type_value_id
	)
END

ELSE IF @flag = 'a' -- Conversion window
BEGIN
	--SELECT * FROM ems_static_data_value where type_id = 31
	SELECT ic.[type_id],
		t.Code,
		t.[Description],
		CASE WHEN static_data_type IS NULL THEN 'n' ELSE 'y' END SystemDefine,
		ei.constant_value Constant,
		t.static_data_type
	FROM ems_input_characteristics ic
	INNER JOIN ems_static_data_type t ON t.[type_id] = ic.[type_id]
	INNER JOIN ems_source_input ei ON ei.ems_source_input_id = ic.ems_source_input_id
	WHERE ic.ems_source_input_id = @ems_source_input_id
END

ELSE IF @flag = 'b' -- Conversion window
BEGIN
	--select * from ems_static_data_value where type_id=31
	SELECT ic.[type_id],
		t.Code,
		t.[Description],
		CASE WHEN static_data_type IS NULL THEN 'n' ELSE 'y' END SystemDefine,
		ei.constant_value Constant,
		t.static_data_type
		--,v.subsequent_value_id
	FROM ems_input_characteristics ic
	INNER JOIN ems_static_data_type t ON t.[type_id] = ic.[type_id]
	--LEFT JOIN ems_static_data_value v ON t.type_id=v.type_id
	INNER JOIN ems_source_input ei ON ei.ems_source_input_id = ic.ems_source_input_id
	WHERE ic.ems_source_input_id = @ems_source_input_id
	--group by ic.type_id, t.Code,t.Description,case when static_data_type is null then 'n' else 'y' end,
	--ei.constant_value,t.static_data_type,v.subsequent_value_id
	ORDER BY ic.sequence_id
END

ELSE IF @flag = 'm' -- show all characteristics for the selected input
BEGIN
	SELECT c.type_char_id,
		e.input_name,
		t.[description] Characteristics
	FROM EMS_SOURCE_INPUT e
	INNER JOIN ems_input_characteristics c ON e.ems_source_input_id = c.ems_source_input_id
	INNER JOIN ems_static_data_type t ON c.[type_id] = t.[type_id]
	WHERE e.ems_source_input_id = @ems_source_input_id
	ORDER BY c.sequence_id
END

ELSE IF @flag = 'i'
BEGIN
	DECLARE @count INT
	SELECT @count = COUNT(*) FROM ems_input_characteristics eic WHERE eic.ems_source_input_id = @ems_source_input_id
	
	IF NOT EXISTS (
		SELECT ems_conversion_type_value_id FROM ems_input_characteristics eic 
		INNER JOIN ems_conversion_type ect ON ect.type_char_id = eic.type_char_id
		WHERE eic.[type_id] = @type_id AND eic.ems_source_input_id = @ems_source_input_id
	)
	BEGIN
		IF(@count >= 10)
		BEGIN
			EXEC spa_ErrorHandler 0,
				'The selected characteristic is already used.',
				'spa_ems_input_characteristics',
				'Exceed',
				'Characterics Limit Exceeded.',
				''
			RETURN
		END
	END

	SELECT @type_char_id = type_char_id
	FROM ems_input_characteristics
	WHERE ems_source_input_id = @ems_source_input_id AND [type_id] = @type_id
	
	SELECT @sequence_id = MAX(sequence_id)
	FROM ems_input_characteristics
	WHERE ems_source_input_id = @ems_source_input_id

	IF @type_char_id IS NULL
	BEGIN
		INSERT INTO ems_input_characteristics ([type_id], ems_source_input_id, sequence_id)
		VALUES (@type_id, @ems_source_input_id, ISNULL(@sequence_id + 1, 1))

		SET @type_char_id = SCOPE_IDENTITY()
	END

	INSERT INTO ems_conversion_type (ems_conversion_type_value_id, ems_source_input_id, type_char_id)
 	VALUES (@ems_conversion_type_value_id, @ems_source_input_id, @type_char_id)
 	
	SET @errorCode = @@ERROR
	IF @errorCode <> 0
	BEGIN
		EXEC spa_ErrorHandler @errorCode,
			'StaticDataMgmt',
			'spa_StaticDataValue',
			'DB Error',
			'Failed to insert static data value.',
			''
	END
	ELSE
	BEGIN
		EXEC spa_ErrorHandler 0,
			'StaticDataMgmt',
			'spa_StaticDataValue',
			'Success',
			'Static data value inserted.',
			''
	END
END

--exec spa_ems_input_characteristics 'd',60,NULL,NULL,NULL
ELSE IF @flag = 'd'
BEGIN
	SELECT @sequence_id = sequence_id,
		@ems_source_input_id=ems_source_input_id
	FROM ems_input_characteristics
	WHERE type_char_id = @type_char_id

	DECLARE @value INT

	IF @sequence_id = 1
		SELECT @value = MAX(char1) FROM ems_source_conversion WHERE ems_source_input_id = @ems_source_input_id
	ELSE IF @sequence_id = 2
		SELECT @value = MAX(char2) FROM ems_source_conversion WHERE ems_source_input_id = @ems_source_input_id
	ELSE IF @sequence_id = 3
		SELECT @value = MAX(char3) FROM ems_source_conversion WHERE ems_source_input_id = @ems_source_input_id
	ELSE IF @sequence_id = 4
		SELECT @value = MAX(char4) FROM ems_source_conversion WHERE ems_source_input_id = @ems_source_input_id
	ELSE IF @sequence_id = 5
		SELECT @value = MAX(char5) FROM ems_source_conversion WHERE ems_source_input_id = @ems_source_input_id
	ELSE IF @sequence_id = 6
		SELECT @value = MAX(char6) FROM ems_source_conversion WHERE ems_source_input_id = @ems_source_input_id
	ELSE IF @sequence_id = 7
		SELECT @value = MAX(char7) FROM ems_source_conversion WHERE ems_source_input_id = @ems_source_input_id
	ELSE IF @sequence_id = 8
		SELECT @value = MAX(char8) FROM ems_source_conversion WHERE ems_source_input_id = @ems_source_input_id
	ELSE IF @sequence_id = 9
		SELECT @value = MAX(char9) FROM ems_source_conversion WHERE ems_source_input_id = @ems_source_input_id
	ELSE IF @sequence_id = 10
		SELECT @value = MAX(char10) FROM ems_source_conversion WHERE ems_source_input_id = @ems_source_input_id

	IF @value IS NOT NULL
	BEGIN
		SET @errorCode = 1
		EXEC spa_ErrorHandler @errorCode,
			'The selected characteristic is used in emisssion conversion factor.',
			'spa_ems_input_characteristics',
			'DB Error',
			'',
			''
		RETURN
	END
	ELSE
	BEGIN
		BEGIN TRY
			BEGIN TRAN
				DELETE ems_conversion_type WHERE type_char_id = @type_char_id AND ems_conversion_type_value_id = @ems_conversion_type_value_id

				IF NOT EXISTS(SELECT 1 FROM ems_conversion_type WHERE type_char_id = @type_char_id)
					DELETE ems_input_characteristics WHERE type_char_id = @type_char_id

				EXEC spa_ErrorHandler 0, 'StaticDataMgmt',
					'spa_StaticDataValue',
					'Success',
					'Static data value deleted.', ''
						
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			DECLARE @error_no INT
			SELECT @error_no = ERROR_NUMBER()
			
			EXEC spa_ErrorHandler @errorCode, 'StaticDataMgmt', 
				'spa_StaticDataValue', 'DB Error', 
				'Failed to delete static data value.', ''
			
			IF (@@TRANCOUNT > 0)			
				ROLLBACK TRAN
		END CATCH
	END
END

GO