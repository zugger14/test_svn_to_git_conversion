SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 4306)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (4306, 4300, 'Trade Ticket Collection', 'Trade Ticket Collection', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 4306 - Trade Ticket Collection.'
END
ELSE
BEGIN
	PRINT 'Static data value 4306 - Trade Ticket Collection already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
