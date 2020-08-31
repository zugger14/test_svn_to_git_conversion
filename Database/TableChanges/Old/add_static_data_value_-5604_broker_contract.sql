SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5604)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5604, 5500, 'Broker Contract', 'Broker Contract', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5604 - Broker Contract.'
END
ELSE
BEGIN
	PRINT 'Static data value -5604 - Broker Contract already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF