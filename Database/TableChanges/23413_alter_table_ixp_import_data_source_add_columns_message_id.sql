IF COL_LENGTH('ixp_import_data_source', 'message_id') IS NULL
BEGIN
	ALTER TABLE ixp_import_data_source
	ADD message_id INT
END

IF COL_LENGTH('ixp_import_data_source', 'error_message_id') IS NULL
BEGIN
	ALTER TABLE ixp_import_data_source
	ADD error_message_id INT
END

