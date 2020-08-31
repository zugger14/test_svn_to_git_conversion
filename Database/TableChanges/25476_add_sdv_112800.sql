IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 112800)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (112800, 'Separator', 'Separator', 1, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 112800 - Separator.'
END
ELSE
BEGIN
    PRINT 'Static data type 112800 - Separator already EXISTS.'
END            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112801)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112800, 112801, 'Decimal', 'Decimal separator', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112801 - Decimal.'
END
ELSE
BEGIN
    PRINT 'Static data value 112801 - Decimal already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112800)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112800, 112800, 'Comma', 'Comma Separator', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112800 - Comma.'
END
ELSE
BEGIN
    PRINT 'Static data value 112800 - Comma already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            