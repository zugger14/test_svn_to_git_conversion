SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 109701)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (109700, 109701, 'Report Manager Report', 'Report Manager Report', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 109701 - Report Manager Report.'
END
ELSE
BEGIN
    PRINT 'Static data value 109701 - Report Manager Report already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF