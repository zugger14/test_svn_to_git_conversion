/*
 Vishwas Khanal
 Defect Id : 2252
 Capturing of Activity Type so that we can have hyperlinks in the message board for two different "Import" UIs.
*/
IF NOT EXISTS (SELECT 'x' FROM information_schema.columns where table_name = 'process_risk_controls' and column_name = 'activity_type')
	ALTER TABLE process_risk_controls ADD activity_type VARCHAR(10)

GO

IF NOT EXISTS (SELECT 'X' FROM static_data_type WHERE type_id = 13700)
BEGIN
	INSERT INTO static_data_type (type_id,type_name,internal,description) SELECT 13700,'Activity Type',1,'Activity Type'

	SET IDENTITY_INSERT static_data_value ON

	INSERT INTO static_data_value (value_id,type_id,code,description) SELECT 13700,13700,'Import from data file','Import from data file'

	INSERT INTO static_data_value (value_id,type_id,code,description) SELECT 13701,13700,'Import from EPA','Import from EPA'

	SET IDENTITY_INSERT static_data_value OFF
END









