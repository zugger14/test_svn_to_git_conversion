SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22520)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (22520, 22500, 'Report Manager Report', 'Report Manager Report', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 22520 - Report Manager Report.'
END
ELSE
BEGIN
    PRINT 'Static data value 22520 - Report Manager Report already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF