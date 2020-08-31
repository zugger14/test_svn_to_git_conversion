SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -900)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-900, 800, 'FieldValue', 'Returns value define in UDF', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -900 - FieldValue.'
END
ELSE
BEGIN
	PRINT 'Static data value -900 - FieldValue already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
