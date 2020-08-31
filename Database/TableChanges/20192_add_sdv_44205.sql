SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44205)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44205, 44200, 'Plot Test Data Range', 'Plot Test Data Range', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44205 - Plot Test Data Range.'
END
ELSE
BEGIN
    PRINT 'Static data value 44205 - Plot Test Data Range already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
