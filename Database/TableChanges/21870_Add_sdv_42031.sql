SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42031)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42031, 42000, 'Invoice ', 'Word Base Invoice', '38', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42031 - Invoice .'
END
ELSE
BEGIN
    PRINT 'Static data value 42031 - Invoice  already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF