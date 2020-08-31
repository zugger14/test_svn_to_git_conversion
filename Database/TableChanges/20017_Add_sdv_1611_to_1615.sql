SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 1615)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (1615, 1600, 'Deemed', 'Deemed', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 1615 - Deemed.'
END
ELSE
BEGIN
    PRINT 'Static data value 1615 - Deemed already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 1614)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (1614, 1600, 'Previous Fortnight', 'Previous Fortnight', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 1614 - Previous Fortnight.'
END
ELSE
BEGIN
    PRINT 'Static data value 1614 - Previous Fortnight already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 1613)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (1613, 1600, 'Previous Month Average', 'Previous Month Average', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 1613 - Previous Month Average.'
END
ELSE
BEGIN
    PRINT 'Static data value 1613 - Previous Month Average already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 1612)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (1612, 1600, 'Prior Week Average', 'Prior Week Average', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 1612 - Prior Week Average.'
END
ELSE
BEGIN
    PRINT 'Static data value 1612 - Prior Week Average already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 1611)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (1611, 1600, 'Monthly Average', 'Monthly Average', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 1611 - Monthly Average.'
END
ELSE
BEGIN
    PRINT 'Static data value 1611 - Monthly Average already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF