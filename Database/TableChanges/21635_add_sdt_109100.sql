IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 109100)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (109100, 'SaaS Website User Type', 'Types of users for SaaS Website', 1, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 109100 - SaaS Website User Type.'
END
ELSE
BEGIN
    PRINT 'Static data type 109100 - SaaS Website User Type already EXISTS.'
END