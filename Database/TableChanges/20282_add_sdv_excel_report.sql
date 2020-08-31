SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 310367)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (310367, 10008, 'Excel Reports', 'Excel Reports', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 310367 - Excel Reports.'
END
ELSE
BEGIN
	PRINT 'Static data value 310367 - Excel Reports already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF