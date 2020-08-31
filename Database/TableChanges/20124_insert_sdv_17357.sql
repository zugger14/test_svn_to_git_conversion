SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17357)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (17357, 17350, 'GMaR ', 'GMaR ', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 17357 - GMaR .'
END
ELSE
BEGIN
    PRINT 'Static data value 17357 - GMaR  already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF