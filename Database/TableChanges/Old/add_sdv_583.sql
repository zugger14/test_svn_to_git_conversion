SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 583)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (583, 575, 'Contract Price', 'Contract Price', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 583 - Contract Price.'
END
ELSE
BEGIN
	PRINT 'Static data value 583 - Contract Price already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

