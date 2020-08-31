SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -43000)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-43000, 43000, 'Signature', 'Signature', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -43000 - Signature.'
END
ELSE
BEGIN
    PRINT 'Static data value -43000 - Signature already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


