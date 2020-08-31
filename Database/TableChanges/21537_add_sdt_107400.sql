IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 107400)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (107400, 'Product Classification', 'Product Classification', 1, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 107400 - Product Classification.'
END
ELSE
BEGIN
    PRINT 'Static data type 107400 - Product Classification already EXISTS.'
END