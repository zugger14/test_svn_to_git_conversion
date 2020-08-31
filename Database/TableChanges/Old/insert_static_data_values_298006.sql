SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 298006)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (298006, 800, 'GetBookID', 'Returns the ID of particular book name.', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 298006 - GetBookID.'
END
ELSE
BEGIN
	PRINT 'Static data value 298006 - GetBookID already EXISTS.'
END
SET 
IDENTITY_INSERT static_data_value OFF