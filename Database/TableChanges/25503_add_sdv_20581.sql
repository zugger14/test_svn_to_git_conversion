SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20581)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (20500, 20581, 'Post MTM Calculation', 'Post MTM Calculation', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20581 - Post MTM Calculation.'
END
ELSE
BEGIN
    PRINT 'Static data value 20581 - Post MTM Calculation already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF