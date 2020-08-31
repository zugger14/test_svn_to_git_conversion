SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 298007)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (298007, 800, 'Value', 'Returns the same as input.', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 298007 - Value.'
END
ELSE
BEGIN
	PRINT 'Static data value 298007 - Value already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF