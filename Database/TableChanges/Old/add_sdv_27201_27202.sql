SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27201)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (27201, 27200, 'Matched', 'Matched', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 27201 - Matched.'
END
ELSE
BEGIN
	PRINT 'Static data value 27201 - Matched already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27202)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (27202, 27200, 'Unmatched', 'Unmatched', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 27202 - Unmatched.'
END
ELSE
BEGIN
	PRINT 'Static data value 27202 - Unmatched already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF