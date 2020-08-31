SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18731)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (18731, 18700, 'Injection based Fee', 'Injection based Fee', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 18731 - Injection based Fee.'
END
ELSE
BEGIN
    PRINT 'Static data value 18731 - Injection based Fee already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF