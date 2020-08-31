SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 46709)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (46709, 46700, 'Financial', 'Financial', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 46709 - Financial.'
END
ELSE
BEGIN
    PRINT 'Static data value 46709 - Financial already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 46708)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (46708, 46700, 'Physical', 'Physical', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 46708 - Physical.'
END
ELSE
BEGIN
    PRINT 'Static data value 46708 - Physical already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 46707)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (46707, 46700, 'Cash', 'Cash', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 46707 - Cash.'
END
ELSE
BEGIN
    PRINT 'Static data value 46707 - Cash already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF