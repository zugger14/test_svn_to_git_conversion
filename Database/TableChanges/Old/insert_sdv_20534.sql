SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20534)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20534, 20500, 'Calendar - Instance', ' Calendar - Instance', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20534 - Calendar - Instance.'
END
ELSE
BEGIN
    PRINT 'Static data value 20534 - Calendar - Instance already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF