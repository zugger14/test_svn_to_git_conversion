SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -43001)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (43000, -43001, 'Template', 'Template', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -43001 - Template.'
END
ELSE
BEGIN
    PRINT 'Static data value -43001 - Template already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            