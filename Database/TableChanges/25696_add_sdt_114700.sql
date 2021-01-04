IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 114700)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (114700, 'Contract Category', 'Contract Category', 0, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 114700 - Contract Category.'
END
ELSE
BEGIN
    PRINT 'Static data type 114700 - Contract Category already EXISTS.'
END            