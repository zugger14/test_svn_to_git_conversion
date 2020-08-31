IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 110200)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (110200, 'Proxy Position Type', 'Proxy Position Type', 1, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 110200 - Proxy Position Type.'
END
ELSE
BEGIN
    PRINT 'Static data type 110200 - Proxy Position Type already EXISTS.'
END            