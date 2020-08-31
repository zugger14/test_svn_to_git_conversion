UPDATE static_data_value
    SET code = 'Deal Required Documents',
    [category_id] = ''
    WHERE [value_id] = 42003
PRINT 'Updated Static value 42003 - Deal Required Documents.'
GO

UPDATE static_data_value
    SET code = 'Deal Status',
    [category_id] = 33
    WHERE [value_id] = 42004
PRINT 'Updated Static value 42004 - Deal Status.'
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42018)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42018, 42000, 'Deal Confirm', ' Deal Confirm', '33', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42018 - Deal Confirm.'
END
ELSE
BEGIN
    PRINT 'Static data value 42018 - Deal Confirm already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO