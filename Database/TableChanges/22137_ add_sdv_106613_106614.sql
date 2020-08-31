SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106613 AND type_id = 106600)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106613, 106600, 'Previous Month Average 6-0-0', 'Previous Month Average 6-0-0', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106613 - Previous Month Average 6-0-0.'
END
ELSE
BEGIN
    PRINT 'Static data value 106613 - Previous Month Average 6-0-0 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106614 AND type_id = 106600)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106614, 106600, 'Previous Month Average 6-1-0', 'Previous Month Average 6-1-0', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106614 - Previous Month Average 6-1-0.'
END
ELSE
BEGIN
    PRINT 'Static data value 106614 - Previous Month Average 6-1-0 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF