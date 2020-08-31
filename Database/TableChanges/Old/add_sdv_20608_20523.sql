SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20608)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20608, 20600, 'Nomination', 'Nomination', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20608 - Nomination.'
END
ELSE
BEGIN
	PRINT 'Static data value 20608 - Nomination already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20523)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20523, 20500, 'Nomination - Post Confirmation Send', 'Nomination - Post Confirmation Send', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20523 - Nomination - Post Confirmation Send.'
END
ELSE
BEGIN
	PRINT 'Static data value 20523 - Nomination - Post Confirmation Send already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

