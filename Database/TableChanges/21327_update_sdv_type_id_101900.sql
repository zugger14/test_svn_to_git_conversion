SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 101900)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (101900, 101900, 'Transportation rate schedule-Fixed', 'Transportation rate schedule-Fixed', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 101900 - Transportation rate schedule-Fixed.'
END
ELSE
BEGIN
    PRINT 'Static data value 101900 - Transportation rate schedule-Fixed already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

UPDATE static_data_value SET Code='Transportation rate schedule-Fixed',description='Transportation rate schedule-Fixed' WHERE value_id = 101900 AND type_id=101900


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 101901)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (101901, 101900, 'Transportation rate schedule-Variable', 'Transportation rate schedule-Variable', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 101901 - Transportation rate schedule-Variable.'
END
ELSE
BEGIN
    PRINT 'Static data value 101900 - Transportation rate schedule-Variable already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


UPDATE static_data_value SET Code='Transportation rate schedule-Variable',description='Transportation rate schedule-Variable' WHERE value_id = 101901 AND type_id=101900

