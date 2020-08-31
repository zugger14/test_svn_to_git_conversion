SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5716)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5716, 5500, 'Internal Desk', 'Internal Desk', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5716 - Internal Desk.'
END
ELSE
BEGIN
	PRINT 'Static data value -5716 - Internal Desk already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
