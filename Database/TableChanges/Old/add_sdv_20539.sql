SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20539)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20539, 20500, 'Post - Assign Transaction', ' Post Assign Transaction', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20539 - Post - Assign Transaction.'
END
ELSE
BEGIN
    PRINT 'Static data value 20539 - Post - Assign Transaction already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF