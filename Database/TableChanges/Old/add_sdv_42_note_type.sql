SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (42, 25, 'Designation of Hedge', 'Designation of Hedge', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 42 - Designation of Hedge.'
END
ELSE
BEGIN
	PRINT 'Static data value 42 - Designation of Hedge already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
