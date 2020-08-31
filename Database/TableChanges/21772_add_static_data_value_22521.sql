SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22521)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (22521, 22500, 'Regression Type Calculation', 'Regression Type Calculation', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 22521 - Regression Type Calculation.'
END
ELSE
BEGIN
    PRINT 'Static data value 22521 - Regression Type Calculation already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF