SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20612)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20612, 20600, 'Measurement', ' Trigger measurement process', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20612 - Measurement.'
END
ELSE
BEGIN
    PRINT 'Static data value 20612 - Measurement already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20533)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20533, 20500, 'Measurement- Post link finalize', ' Trigger measurement process for given as of date once the associated links are finalized.', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20533 - Measurement- Post link finalize.'
END
ELSE
BEGIN
    PRINT 'Static data value 20533 - Measurement- Post link finalize already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

