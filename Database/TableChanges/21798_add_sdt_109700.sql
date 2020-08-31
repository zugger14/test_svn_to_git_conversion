IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 109700)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (109700, 'Regression Testing Setup Type', 'Regression Testing Setup Type', 1, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 109700 - Regression Testing Setup Type.'
END
ELSE
BEGIN
    PRINT 'Static data type 109700 - Regression Testing Setup Type already EXISTS.'
END