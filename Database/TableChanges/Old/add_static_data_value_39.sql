SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 39)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (39, 25, 'Broadcast', 'Broadcast', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 39 - Broadcast.'
END
ELSE
BEGIN
	PRINT 'Static data value 39 - Broadcast already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
