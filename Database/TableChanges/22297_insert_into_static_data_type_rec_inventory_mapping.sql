IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 111700)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (111700, 'REC Inventory Mapping', 'REC Inventory Mapping', 0, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 111700 - REC Inventory Mapping.'
END
ELSE
BEGIN
    PRINT 'Static data type 111700 - REC Inventory Mapping already EXISTS.'
END            