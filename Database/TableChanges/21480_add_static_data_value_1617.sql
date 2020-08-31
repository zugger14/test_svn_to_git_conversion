SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 1617)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (1600, 1617, 'Entire Average Market', 'Entire Average Market', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 1617 - Entire Average Market.'
END
ELSE
BEGIN
    PRINT 'Static data value 1617 - Entire Average Market already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF  