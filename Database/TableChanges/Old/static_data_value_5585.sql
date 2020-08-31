SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5585)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5585, 5500, 'Pratos_Timestamp', 'Pratos Time Stamp', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5585 - Pratos_Timestamp.'
END
ELSE
BEGIN
	PRINT 'Static data value -5585 - Pratos_Timestamp already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
