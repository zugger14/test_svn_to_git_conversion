SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17813)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (17813, 17800, 'FARRMS FIX Protocol Service Email Template', 'Email template for FARRMS FIX Protocol Service notifications', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 17813 - FARRMS FIX Protocol Service Email Template.'
END
ELSE
BEGIN
    PRINT 'Static data value 17813 - FARRMS FIX Protocol Service Email Template already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF