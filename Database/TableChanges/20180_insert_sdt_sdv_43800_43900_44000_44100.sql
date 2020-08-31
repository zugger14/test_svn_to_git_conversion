-- sdt 43800 and its value
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 43800)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (43800, 'Forecast Type', 1, 'Forecast Type', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 43800 - Forecast Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 43800 - Forecast Type already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 43801)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (43801, 43800, 'Load Forecast', ' Load Forecast', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 43801 - Load Forecast.'
END
ELSE
BEGIN
    PRINT 'Static data value 43801 - Load Forecast already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 43802)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (43802, 43800, 'Price Forecast', ' Price Forecast', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 43802 - Price Forecast.'
END
ELSE
BEGIN
    PRINT 'Static data value 43802 - Price Forecast already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 43803)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (43803, 43800, 'Waterflow Forecast', ' Waterflow Forecast', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 43803 - Waterflow Forecast.'
END
ELSE
BEGIN
    PRINT 'Static data value 43803 - Waterflow Forecast already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF



-- sdt 43900 and its value
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 43900)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (43900, 'Forecast Category', 1, 'Forecast Category', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 43900 - Forecast Category.'
END
ELSE
BEGIN
	PRINT 'Static data type 43900 - Forecast Category already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 43901)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (43901, 43900, 'Short Term', ' Short Term', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 43901 - Short Term.'
END
ELSE
BEGIN
    PRINT 'Static data value 43901 - Short Term already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 43902)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (43902, 43900, 'Long Term', ' Long Term', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 43902 - Long Term.'
END
ELSE
BEGIN
    PRINT 'Static data value 43902 - Long Term already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 43903)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (43903, 43900, 'Both', ' Both', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 43903 - Both.'
END
ELSE
BEGIN
    PRINT 'Static data value 43903 - Both already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF



-- sdt 44000 and its value
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 44000)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (44000, 'Forecast Series Type', 1, 'Forecast Series Type', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 44000 - Forecast Series Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 44000 - Forecast Series Type already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44001)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44001, 44000, 'Calendar Attributes', ' Calendar Attributes', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44001 - Calendar Attributes.'
END
ELSE
BEGIN
    PRINT 'Static data value 44001 - Calendar Attributes already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44002)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44002, 44000, 'Time Series', ' Time Series', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44002 - Time Series.'
END
ELSE
BEGIN
    PRINT 'Static data value 44002 - Time Series already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44003)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44003, 44000, 'Price Curve', ' Price Curve', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44003 - Price Curve.'
END
ELSE
BEGIN
    PRINT 'Static data value 44003 - Price Curve already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44004)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44004, 44000, 'Load', ' Load', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44004 - Load.'
END
ELSE
BEGIN
    PRINT 'Static data value 44004 - Load already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF



-- sdt 44100 and its value
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 44100)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (44100, 'Forecast Series', 1, 'Forecast Series', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 44100 - Forecast Series.'
END
ELSE
BEGIN
	PRINT 'Static data type 44100 - Forecast Series already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44101)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44101, 44100, 'Weekday', ' Weekday', '44001', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44101 - Weekday.'
END
ELSE
BEGIN
    PRINT 'Static data value 44101 - Weekday already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44102)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44102, 44100, 'Holiday', ' Holiday', '44001', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44102 - Holiday.'
END
ELSE
BEGIN
    PRINT 'Static data value 44102 - Holiday already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44103)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44103, 44100, 'Dew Point', ' Dew Point', '44002', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44103 - Dew Point.'
END
ELSE
BEGIN
    PRINT 'Static data value 44103 - Dew Point already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44104)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44104, 44100, 'Temperature', ' Temperature
', '44002', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44104 - Temperature.'
END
ELSE
BEGIN
    PRINT 'Static data value 44104 - Temperature already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF