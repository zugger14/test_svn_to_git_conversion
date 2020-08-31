SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42021)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42021, 42000, 'Deal Confirm 2', ' Deal Confirm 2', '33', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42021 - Deal Confirm 2.'
END
ELSE
BEGIN
    PRINT 'Static data value 42021 - Deal Confirm 2 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF