/*
 * Static data value : Excel
 */
 
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27500)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (27500, 27500, 'Excel', 'Excel', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 27500 - Excel.'
END
ELSE
BEGIN
	PRINT 'Static data value 27500 - Excel already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


/*
 * Static data value : CSV
 */

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27501)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (27501, 27500, 'CSV', 'CSV', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 27501 - CSV.'
END
ELSE
BEGIN
	PRINT 'Static data value 27501 - CSV already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


 /*
 * Static data value : Text
 */
 
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27502)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (27502, 27500, 'Text', 'Text', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 27502 - Text.'
END
ELSE
BEGIN
	PRINT 'Static data value 27502 - Text already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
