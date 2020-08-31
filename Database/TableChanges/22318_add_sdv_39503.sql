SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 39503)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (39500, 39503, 'Rejected', 'Rejected', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 39503 - Rejected.'
END
ELSE
BEGIN
    PRINT 'Static data value 39503 - Rejected already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF