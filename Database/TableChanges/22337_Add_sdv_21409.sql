SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 21409)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (21400, 21409, 'Email', 'Email', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 21409 - Email.'
END
ELSE
BEGIN
    PRINT 'Static data value 21409 - Email already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            