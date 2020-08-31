IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 45200)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (45200, 'Rate Category', 1, 'Rate Category', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 45200 - Rate Category.'
END
ELSE
BEGIN
	PRINT 'Static data type 45200 - Rate Category already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45203)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (45203, 45200, 'Zonal - Zonal', 'Zonal - Zonal', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 45203 - Zonal - Zonal.'
END
ELSE
BEGIN
    PRINT 'Static data value 45203 - Zonal - Zonal already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45202)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (45202, 45200, 'Zonal', 'Zonal', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 45202 - Zonal.'
END
ELSE
BEGIN
    PRINT 'Static data value 45202 - Zonal already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45201)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (45201, 45200, 'Mileage Based', 'Mileage Based', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 45201 - Mileage Based.'
END
ELSE
BEGIN
    PRINT 'Static data value 45201 - Mileage Based already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45200)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (45200, 45200, 'Postage Stamp', 'Postage Stamp', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 45200 - Postage Stamp.'
END
ELSE
BEGIN
    PRINT 'Static data value 45200 - Postage Stamp already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF