SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5630)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5630, 5500, 'UP Pkg ID', 'UP Pkg ID', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5630 - UP Pkg ID.'
END
ELSE
BEGIN
	PRINT 'Static data value -5630 - UP Pkg ID already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
