SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000315)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (10007, 10000315, 'AOP', 'AOP', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000315 - AOP.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000315 - AOP already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            