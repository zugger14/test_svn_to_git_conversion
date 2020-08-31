IF EXISTS(SELECT 1 FROM static_data_value WHERE code = 'Approved and Ready to Send' and [type_id] = 17200 and [value_id] <> 17215)
BEGIN
	DELETE FROM static_data_value WHERE code = 'Approved and Ready to Send' and [type_id] = 17200
END

GO
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17215)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	VALUES (17215, 17200, 'Approved and Ready to Send', 'Approved and Ready to Send')
	PRINT 'Inserted static data value 17215'
END
ELSE
BEGIN
	UPDATE static_data_value
	SET code = 'Approved and Ready to Send',
		description = 'Approved and Ready to Send'
	WHERE [type_id] = 17200 AND [value_id] = 17215

	PRINT 'Updated Static data value 17215.'
END
SET IDENTITY_INSERT static_data_value OFF
