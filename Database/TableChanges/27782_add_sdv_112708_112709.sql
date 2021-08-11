SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112708)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112700, 112708, 'Retail-Power', 'Retail-Power', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112708 - Retail-Power.'
END
ELSE
BEGIN
    PRINT 'Static data value 112708 - Retail-Power already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112709)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112700, 112709, 'Retail-Gas', 'Retail-Gas', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112709 - Retail-Gas.'
END
ELSE
BEGIN
    PRINT 'Static data value 112709 - Retail-Gas already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            