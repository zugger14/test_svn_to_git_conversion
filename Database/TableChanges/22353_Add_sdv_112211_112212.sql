SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112211)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112200, 112211, 'Having Prefix', 'Having Prefix', -1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112211 - Having Prefix.'
END
ELSE
BEGIN
    PRINT 'Static data value 112211 - Having Prefix already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112212)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112200, 112212, 'Having File Extension', 'Having File Extension', -1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112212 - Having File Extension.'
END
ELSE
BEGIN
    PRINT 'Static data value 112212 - Having File Extension already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            