SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 41)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (41, 25, 'Hedge Relationship Type', 'Hedge Relationship Type', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 41 - Hedge Relationship Type.'
END
ELSE
BEGIN
	PRINT 'Static data value 41 - Hedge Relationship Type already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
