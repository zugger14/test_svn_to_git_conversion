SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106615 AND type_id = 106600)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106615, 106600, 'Previous Month Average - 2', 'Previous Month Average - 2', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106615 - Previous Month Average - 2.'
END
ELSE
BEGIN
    PRINT 'Static data value 106615 - Previous Month Average - 2 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF