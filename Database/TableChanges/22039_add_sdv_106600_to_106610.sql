BEGIN TRY
	BEGIN TRANSACTION
	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = 106600)
	BEGIN
		INSERT INTO static_data_value (value_id, type_id, code, description)
		VALUES (106600, 106600, 'Calendar Month Average', 'Calendar Month Average')
	END
	ELSE
	BEGIN
		UPDATE static_data_value
		SET code = 'Calendar Month Average', 
			description = 'Calendar Month Average'
		WHERE value_id = 106600
	END
	SET IDENTITY_INSERT static_data_value OFF

	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = 106602)
	BEGIN
		INSERT INTO static_data_value (value_id, type_id, code, description)
		VALUES (106602, 106600, 'COD', 'Deemed')
	END
	ELSE
	BEGIN
		UPDATE static_data_value
		SET code = 'COD', 
			description = 'Deemed'
		WHERE value_id = 106602
	END
	SET IDENTITY_INSERT static_data_value OFF

	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = 106608)
	BEGIN
		INSERT INTO static_data_value (value_id, type_id, code, description)
		VALUES (106608, 106600, 'Deemed', 'Deemed')
	END
	ELSE
	BEGIN
		UPDATE static_data_value
		SET code = 'Deemed', 
			description = 'Deemed'
		WHERE value_id = 106608
	END
	SET IDENTITY_INSERT static_data_value OFF

	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = 106610)
	BEGIN
		INSERT INTO static_data_value (value_id, type_id, code, description)
		VALUES (106610, 106600, 'Last Settle Price', 'Last Settle Price')
	END
	ELSE
	BEGIN
		UPDATE static_data_value
		SET code = 'Last Settle Price', 
			description = 'Last Settle Price'
		WHERE value_id = 106610
	END
	SET IDENTITY_INSERT static_data_value OFF

	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = 106609)
	BEGIN
		INSERT INTO static_data_value (value_id, type_id, code, description)
		VALUES (106609, 106600, 'Next Month Average', 'Next Month Average')
	END
	ELSE
	BEGIN
		UPDATE static_data_value
		SET code = 'Next Month Average', 
			description = 'Next Month Average'
		WHERE value_id = 106609
	END
	SET IDENTITY_INSERT static_data_value OFF

	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = 106603)
	BEGIN
		INSERT INTO static_data_value (value_id, type_id, code, description)
		VALUES (106603, 106600, 'NYMEX ROLL', 'NYMEX ROLL')
	END
	ELSE
	BEGIN
		UPDATE static_data_value
		SET code = 'NYMEX ROLL', 
			description = 'NYMEX ROLL'
		WHERE value_id = 106603
	END
	SET IDENTITY_INSERT static_data_value OFF

	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = 106604)
	BEGIN
		INSERT INTO static_data_value (value_id, type_id, code, description)
		VALUES (106604, 106600, 'Posted Price', 'Posted Price')
	END
	ELSE
	BEGIN
		UPDATE static_data_value
		SET code = 'Posted Price', 
			description = 'Posted Price'
		WHERE value_id = 106604
	END
	SET IDENTITY_INSERT static_data_value OFF

	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = 106605)
	BEGIN
		INSERT INTO static_data_value (value_id, type_id, code, description)
		VALUES (106605, 106600, 'Previous Fortnight', 'Previous Fortnight')
	END
	ELSE
	BEGIN
		UPDATE static_data_value
		SET code = 'Previous Fortnight', 
			description = 'Previous Fortnight'
		WHERE value_id = 106605
	END
	SET IDENTITY_INSERT static_data_value OFF

	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = 106606)
	BEGIN
		INSERT INTO static_data_value (value_id, type_id, code, description)
		VALUES (106606, 106600, 'Previous Month Average', 'Previous Month Average')
	END
	ELSE
	BEGIN
		UPDATE static_data_value
		SET code = 'Previous Month Average', 
			description = 'Previous Month Average'
		WHERE value_id = 106606
	END
	SET IDENTITY_INSERT static_data_value OFF

	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = 106607)
	BEGIN
		INSERT INTO static_data_value (value_id, type_id, code, description)
		VALUES (106607, 106600, 'Prior Week Average', 'Prior Week Average')
	END
	ELSE
	BEGIN
		UPDATE static_data_value
		SET code = 'Prior Week Average', 
			description = 'Prior Week Average'
		WHERE value_id = 106607
	END
	SET IDENTITY_INSERT static_data_value OFF

	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = 106601)
	BEGIN
		INSERT INTO static_data_value (value_id, type_id, code, description)
		VALUES (106601, 106600, 'Trade Month Average', 'Trade Month Average')
	END
	ELSE
	BEGIN
		UPDATE static_data_value
		SET code = 'Trade Month Average', 
			description = 'Trade Month Average'
		WHERE value_id = 106601
	END
	SET IDENTITY_INSERT static_data_value OFF

	COMMIT

	SELECT 'Data successfully inserted' Success
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 1
		ROLLBACK;

	SELECT ERROR_MESSAGE() Error
END CATCH