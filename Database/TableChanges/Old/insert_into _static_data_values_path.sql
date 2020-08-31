DELETE FROM static_data_value WHERE code = 'Path'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5587)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5587, 5500, 'Path', 'Path', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5587 - Path.'
END
ELSE
BEGIN
	PRINT 'Static data value -5587 - Path already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

--select * FROM static_data_value WHERE code = 'Path'



