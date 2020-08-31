SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18730)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (18730, 18700, 'Fees', 'Fees', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 18730 - Fees.'
END
ELSE
BEGIN
    PRINT 'Static data value 18730 - Fees already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF