SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5690)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5690, 5500, 'Logical Name', 'Logical Name', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5690 - Logical Name.'
END
ELSE
BEGIN
	PRINT 'Static data value -5690 - Logical Name already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF