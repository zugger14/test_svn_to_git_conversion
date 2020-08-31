
--inserting external source import for data type id, 4038 (request) and 4039 (response)


IF NOT EXISTS ( SELECT * FROM external_source_import WHERE data_type_id = 4038)
BEGIN
	INSERT INTO external_source_import ( source_system_id, data_type_id)
	VALUES (2, 4038)
END

IF NOT EXISTS ( SELECT * FROM external_source_import WHERE data_type_id = 4039)
BEGIN
	INSERT INTO external_source_import ( source_system_id, data_type_id)
	VALUES (2, 4039)
END
