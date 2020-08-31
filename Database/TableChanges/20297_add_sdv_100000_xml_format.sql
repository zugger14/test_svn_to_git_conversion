--Inserted static data type 100000 - XML Format.
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 100000)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (100000, 'XML Format', 0, 'XML format to export report.', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 100000 - XML Format.'
END
ELSE
BEGIN
	PRINT 'Static data type 100000 - XML Format already EXISTS.'
END

--Inserted static data value -100000 - Standard Note Type.

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -100000)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-100000, 100000, 'Standard Note Type', 'Standard Note Type xml format.', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -100000 - Standard Note Type.'
END
ELSE
BEGIN
    PRINT 'Static data value -100000 - Standard Note Type already EXISTS.'
END

--Inserted static data value -100001 - Standard Attribute Type.

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -100001)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-100001, 100000, 'Standard Attribute Type', 'Standard Attribute Type xml format.', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -100001 - Standard Attribute Type.'
END
ELSE
BEGIN
    PRINT 'Static data value -100001 - Standard Attribute Type already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
