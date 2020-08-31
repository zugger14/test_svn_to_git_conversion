SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20611)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20611, 20600, 'Scheduling', 'Scheduling', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20611 - Scheduling.'
END
ELSE
BEGIN
	PRINT 'Static data value 20611 - Scheduling already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
