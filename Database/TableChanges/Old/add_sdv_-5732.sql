SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5732)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-5732, 5500, 'Package#', ' Package#', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -5732 - Package#.'
END
ELSE
BEGIN
    PRINT 'Static data value -5732 - Package# already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF