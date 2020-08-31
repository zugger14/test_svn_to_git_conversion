IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 108900)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (108900, 'Charge Type Alias', 'Charge Type Alias', 0, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 108900 - Charge Type Alias.'
END
ELSE
BEGIN
    PRINT 'Static data type 108900 - Charge Type Alias already EXISTS.'
END            

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 109000)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (109000, 'PNL Line Item', 'PNL Line Item', 0, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 109000 - PNL Line Item.'
END
ELSE
BEGIN
    PRINT 'Static data type 109000 - PNL Line Item already EXISTS.'
END            