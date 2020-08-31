SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17605)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (17605, 17600, 'Physical Allocation', 'Physical Allocation', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 17605 - Physical Allocation.'
END
ELSE
BEGIN
	PRINT 'Static data value 17605 - Physical Allocation already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
