SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5692)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5692, 5500, 'BIC Code Type', 'BIC Code Type', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5692 - BIC Code Type.'
END
ELSE
BEGIN
	PRINT 'Static data value -5692 - BIC Code Type already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
