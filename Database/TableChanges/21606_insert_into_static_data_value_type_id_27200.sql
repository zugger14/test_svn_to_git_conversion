IF EXISTS (SELECT 1 FROM static_data_value where type_id = 27200 and value_id IN (27205, 27204, 27203, 27202))
	DELETE FROM static_data_value where type_id = 27200 and value_id IN (27205, 27204, 27203, 27202)

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27207)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (27200, 27207, 'Incomplete', 'Incomplete', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 27207 - Incomplete.'
END
ELSE
BEGIN
    PRINT 'Static data value 27207 - Incomplete already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27208)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (27200, 27208, 'Delivered', 'Delivered', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 27208 - Delivered.'
END
ELSE
BEGIN
    PRINT 'Static data value 27208 - Delivered already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27209)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (27200, 27209, 'Exception', 'Exception', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 27209 - Exception.'
END
ELSE
BEGIN
    PRINT 'Static data value 27209 - Exception already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            