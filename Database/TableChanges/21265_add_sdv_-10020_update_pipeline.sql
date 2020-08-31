--######## Update the code of existing static data value

UPDATE static_data_value SET code ='Pipeline Old' WHERE type_id=10020 AND code='Pipeline' AND value_id<>-10021
GO
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT * FROM static_data_value WHERE value_id = -10021)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10021, 10020, 'Pipeline', ' Pipeline', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10020 - Pipeline.'
END
ELSE
BEGIN
    PRINT 'Static data value -10021 - Pipeline already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO
UPDATE sc SET sc.type_of_entity = -10021 FROM source_counterparty sc INNER JOIN static_data_value sdv ON sdv.value_id=sc.type_of_entity AND sdv.type_id=10020 AND sdv.code='Pipeline Old'
UPDATE sc SET sc.type_of_entity = -10021 FROM source_counterparty sc INNER JOIN static_data_value sdv ON sdv.value_id=sc.type_of_entity AND sdv.type_id=10020 AND sdv.code='Pipeline Old'

GO
DELETE FROM static_data_value WHERE type_id=10020 AND code='Pipeline OLD'
--select * FROM static_data_value WHERE type_id=10020 AND code='Pipeline OLD'


