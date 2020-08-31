SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -100003)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (100000, -100003, 'ERP Invoice Type', 'ERP Invoice Type', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -100003 - ERP Invoice Type.'
END
ELSE
BEGIN
    PRINT 'Static data value -100003 - ERP Invoice Type already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF