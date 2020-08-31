IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 112000)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (112000, 'Value Mapping', 'Value Mapping', 1, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 112000 - Value Mapping.'
END
ELSE
BEGIN
    PRINT 'Static data type 112000 - Value Mapping already EXISTS.'
END            