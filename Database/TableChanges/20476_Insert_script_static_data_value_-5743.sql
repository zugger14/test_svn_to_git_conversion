SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5743)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-5743, 5500, 'CSA Reportable Trade', 'CSA_Reportable_Trade', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -5743 - CSA Reportable Trade.'
END
ELSE
BEGIN
    PRINT 'Static data value -5743 - CSA Reportable Trade already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

UPDATE static_data_value
    SET code = 'CSA Reportable Trade',
    [category_id] = ''
    WHERE [value_id] = -5743
PRINT 'Updated Static value -5743 - CSA Reportable Trade.'