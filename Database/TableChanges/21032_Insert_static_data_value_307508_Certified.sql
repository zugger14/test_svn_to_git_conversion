SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 25004 AND type_id = 25000)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (25004, 25000, 'Certified', 'Certified', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 25004 - Certified.'
END
ELSE
BEGIN
    PRINT 'Static data value 25004 - Certified already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF