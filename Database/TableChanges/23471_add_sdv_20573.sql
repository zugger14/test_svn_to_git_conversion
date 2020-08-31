SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20573)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20573, 20500, 'Incident Log Insert/Update', '', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20573 - Incident Log Insert/Update.'
END
ELSE
BEGIN
    PRINT 'Static data value 20573 - Incident Log Insert/Update already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF