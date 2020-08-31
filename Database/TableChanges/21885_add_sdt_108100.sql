IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 108100)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (108100, 'Margin Product', 'Margin Product', 0, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 108100 - Margin Product.'
END
ELSE
BEGIN
    PRINT 'Static data type 108100 - Margin Product already EXISTS.'
END     