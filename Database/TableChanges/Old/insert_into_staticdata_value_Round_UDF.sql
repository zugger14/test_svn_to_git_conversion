SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5632)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5632, 5500, 'Round', 'Round', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5632 - Round UDF.'
END
ELSE
BEGIN
	PRINT 'Static data value -5632 - Round already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF	