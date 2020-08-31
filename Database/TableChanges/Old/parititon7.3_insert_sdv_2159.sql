SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 2159)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (2159, 2150, 'Position', 'Position', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 2159 - Position.'
END
ELSE
BEGIN
	PRINT 'Static data value 2159 - Position already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
