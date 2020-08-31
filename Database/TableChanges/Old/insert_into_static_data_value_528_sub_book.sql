SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 528)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (528, 525, 'Sub Book', 'Sub Book', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 528 - Sub Book.'
END
ELSE
BEGIN
	PRINT 'Static data value 528 - Sub Book already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF	