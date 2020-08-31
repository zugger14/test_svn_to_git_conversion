SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105805)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (105800, 105805, 'Ammendment', 'Ammendment', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105805 - Ammendment.'
END
ELSE
BEGIN
    PRINT 'Static data value 105805 - Ammendment already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF