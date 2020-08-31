SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20509)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20509, 20500, 'Post - Position Calculation', 'Post - Position Calculation', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20509 - Post - Position Calculation.'
END
ELSE
BEGIN
	PRINT 'Static data value 20509 - Post - Position Calculation already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

