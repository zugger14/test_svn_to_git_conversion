IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 112400)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (112400, 'Conversion Name', 'Conversion Name', 0, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 112400 - Conversion Name.'
END
ELSE
BEGIN
    PRINT 'Static data type 112400 - Conversion Name already EXISTS.'
END

        