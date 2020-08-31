SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20568)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20568, 20500, 'Contract Post Insert/Update', 'Contract Post Insert/Update', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20568 - Contract Post Insert.'
END
ELSE
BEGIN
    PRINT 'Static data value 20568 - Contract Post Insert already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF