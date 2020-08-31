SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42048)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (42000, 42048, 'Framework Agreement', 'Framework Agreement', 10000330, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42048 - Framework Agreement.'
END
ELSE
BEGIN
    PRINT 'Static data value 42048 - Framework Agreement already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            


