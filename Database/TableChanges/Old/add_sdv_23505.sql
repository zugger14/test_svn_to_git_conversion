SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 23505)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (23505, 23500, 'Credit Risk', ' Credit Risk', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 23505 - Credit Risk.'
END
ELSE
BEGIN
    PRINT 'Static data value 23505 - Credit Risk already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF