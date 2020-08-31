SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112803)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112800, 112803, 'Space', 'For Greece number format', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112803 - Space.'
END
ELSE
BEGIN
    PRINT 'Static data value 112803 - Space already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112804)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112800, 112804, 'No group separator', 'No group separator', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112804 - No group separator.'
END
ELSE
BEGIN
    PRINT 'Static data value 112804 - No group seperator already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112802)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112800, 112802, 'Apostrophe', 'For Switzerland number format', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112802 - Apostrophe.'
END
ELSE
BEGIN
    PRINT 'Static data value 112802 - Apostrophe already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            