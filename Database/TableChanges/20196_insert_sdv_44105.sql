SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44105)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44105, 44100, 'Peakness', 'Peakness', '44001', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44105 - Peakness.'
END
ELSE
BEGIN
    PRINT 'Static data value 44105 - Peakness already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF