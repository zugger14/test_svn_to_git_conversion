SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 4048)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (4048, 4000, 'ICE Deal Data Import', 'ICE Deal Data Import', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 4048 - ICE Deal Data Import.'
END
ELSE
BEGIN
	PRINT 'Static data value 4048 - ICE Deal Data Import already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS(SELECT 1 FROM external_source_import WHERE data_type_id=4048)
INSERT INTO external_source_import(source_system_id,data_type_id) SELECT 2,4048


