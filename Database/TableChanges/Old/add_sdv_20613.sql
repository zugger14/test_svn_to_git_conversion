SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20613)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20613, 20600, ' Assign Transaction', '  Assign Transaction', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20613 -  Assign Transaction.'
END
ELSE
BEGIN
    PRINT 'Static data value 20613 -  Assign Transaction already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF