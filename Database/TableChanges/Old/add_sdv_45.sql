SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (45, 25, 'Schedule Match', 'Schedule Match', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 45 - Schedule Match.'
END
ELSE
BEGIN
	PRINT 'Static data value 45 - Schedule Match already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
