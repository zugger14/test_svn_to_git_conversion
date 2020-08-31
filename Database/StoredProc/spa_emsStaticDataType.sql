IF OBJECT_ID(N'[dbo].[spa_emsStaticDataType]', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_emsStaticDataType]
 GO 



CREATE PROCEDURE [dbo].[spa_emsStaticDataType]	
	@flag AS CHAR(1)
	,@type_id AS INT = NULL
	,@code AS VARCHAR(100) = NULL
	,@description AS VARCHAR(250) = NULL
	,@ems_source_input_id INT = NULL

AS

SET NOCOUNT ON

DECLARE @errorCode INT

IF @flag = 's' 
BEGIN
	SELECT type_id,code Characteristics,description AS Description  FROM ems_static_data_type
	WHERE static_data_type is null
	ORDER BY code
	--WHERE  ems_source_input_id=@ems_source_input_id

END
ELSE IF @flag = 'a' 
BEGIN
	SELECT type_id,code,description FROM ems_static_data_type
	WHERE type_id=@type_id
	
END
ELSE IF @flag='i'
BEGIN
    IF EXISTS (SELECT  code FROM ems_static_data_type WHERE code=@code)
	BEGIN
		EXEC spa_ErrorHandler 1, 'Duplicate characteristics cannot be inserted.', 
						'spa_StaticDataValue', 'DB Error', 
						'Failed to insert static data value.', ''
	END
	ELSE
	BEGIN
			
		INSERT INTO ems_static_data_type
		(code,description)
		VALUES (@code,@description)



		SET @errorCode = @@ERROR
		IF @errorCode <> 0
			EXEC spa_ErrorHandler @errorCode, 'StaticDataMgmt', 
					'spa_StaticDataValue', 'DB Error', 
					'Failed to insert static data value.', ''
		ELSE
			EXEC spa_ErrorHandler 0, 'StaticDataMgmt', 
					'spa_StaticDataValue', 'Success', 
					'Static data value inserted.', ''
		END
	END

ELSE IF @flag = 'u'
BEGIN
	IF EXISTS (SELECT  code FROM ems_static_data_type WHERE code=@code and type_id <> @type_id)
	BEGIN
		EXEC spa_ErrorHandler 1, 'Duplicate characteristics cannot be inserted.', 
			'spa_StaticDataValue', 'DB Error', 
			'Failed to insert static data value.', ''
	END
	ELSE
	BEGIN
		UPDATE ems_static_data_type
		SET code = @code, description = @description
		WHERE type_id = @type_id

		SET @errorCode = @@ERROR
		IF @errorCode <> 0
		BEGIN
			
			EXEC spa_ErrorHandler @errorCode, 'StaticDataMgmt', 
					'spa_StaticDataValue', 'DB Error', 
					'Failed to update static data value.', ''
			RETURN
		END
		ELSE
		BEGIN
			
			EXEC spa_ErrorHandler 0, 'StaticDataMgmt', 
					'spa_StaticDataValue', 'Success', 
					'Static data value updated.', ''
			RETURN
		END
	END
END

ELSE IF @flag='d'
BEGIN
	IF EXISTS (SELECT 1 FROM ems_static_data_value WHERE type_id = @type_id)
	BEGIN 
		EXEC spa_ErrorHandler -1, 'StaticDataMgmt', 
				'spa_StaticDataValue', 'DB Error', 
				'Please delete Input Characteristics Detail first.', ''
		RETURN
	END
	DELETE ems_static_data_type WHERE type_id = @type_id

	SET @errorCode = @@ERROR
	IF @errorCode <> 0
	BEGIN
		EXEC spa_ErrorHandler @errorCode, 'StaticDataMgmt', 
				'spa_StaticDataValue', 'DB Error', 
				'Failed to delete static data value.', ''
		RETURN
	END
	ELSE
	BEGIN
		EXEC spa_ErrorHandler 0, 'StaticDataMgmt', 
				'spa_StaticDataValue', 'Success', 
				'Static data value deleted.', ''
		RETURN
	END
END










