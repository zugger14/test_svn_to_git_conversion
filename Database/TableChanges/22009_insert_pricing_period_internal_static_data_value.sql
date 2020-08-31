BEGIN TRY
	BEGIN TRANSACTION
	IF NOT EXISTS (SELECT 1 FROM static_data_type WHERE type_id = 106600)
	BEGIN
		INSERT INTO static_data_type (type_id, type_name, internal, description, is_active)
		VALUES (106600, 'Pricing Period', 1, 'Pricing Period', 1)
	END

	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = 106600)
	BEGIN
		INSERT INTO static_data_value (value_id, type_id, code, description)
		VALUES (106600, 106600, 'CalendarMonthAverage', 'CalendarMonthAverage')
	END
	SET IDENTITY_INSERT static_data_value OFF

	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = 106602)
	BEGIN
		INSERT INTO static_data_value (value_id, type_id, code, description)
		VALUES (106602, 106600, 'Deemed', 'Deemed')
	END
	SET IDENTITY_INSERT static_data_value OFF
	
	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = 106603)
	BEGIN
		INSERT INTO static_data_value (value_id, type_id, code, description)
		VALUES (106603, 106600, 'NYMEXROLL', 'NYMEXROLL')
	END
	SET IDENTITY_INSERT static_data_value OFF
	
	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = 106604)
	BEGIN
		INSERT INTO static_data_value (value_id, type_id, code, description)
		VALUES (106604, 106600, 'PostedPrice', 'PostedPrice')
	END
	SET IDENTITY_INSERT static_data_value OFF	   
	
	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = 106605)
	BEGIN
		INSERT INTO static_data_value (value_id, type_id, code, description)
		VALUES (106605, 106600, 'PreviousFortnight', 'PreviousFortnight')
	END
	SET IDENTITY_INSERT static_data_value OFF
	
	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = 106606)
	BEGIN
		INSERT INTO static_data_value (value_id, type_id, code, description)
		VALUES (106606, 106600, 'PreviousMonthAverage', 'PreviousMonthAverage')
	END
	SET IDENTITY_INSERT static_data_value OFF

	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = 106607)
	BEGIN
		INSERT INTO static_data_value (value_id, type_id, code, description)
		VALUES (106607, 106600, 'PriorWeekAverage', 'PriorWeekAverage')
	END
	SET IDENTITY_INSERT static_data_value OFF
	
	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = 106601)
	BEGIN
		INSERT INTO static_data_value (value_id, type_id, code, description)
		VALUES (106601, 106600, 'TradeMonthAverage', 'TradeMonthAverage')
	END
	SET IDENTITY_INSERT static_data_value OFF	   
		   
	COMMIT 

	SELECT 'Pricing Period inserted successfully.' [Message]
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK
	
	SELECT 'Error occurred while inserting Pricing Period. Error :- ' + ERROR_MESSAGE() [Message]
END CATCH