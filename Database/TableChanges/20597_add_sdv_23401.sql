SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 23401)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (23401, 23400, 'Constraint', 'Constraint', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 23401 - Constraint.'
END
ELSE
BEGIN
	PRINT 'Static data value 23401 - Constraint already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
