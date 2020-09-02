SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112707)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112700, 112707, 'Storage ST', 'Storage ST', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112707 - Storage ST.'
END
ELSE
BEGIN
    PRINT 'Static data value 112707 - Storage ST already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

GO