IF NOT EXISTS (SELECT 1 FROM external_source_import esi WHERE data_type_id = 4043 AND esi.source_system_id = 2)
BEGIN
	INSERT INTO external_source_import
	(
		source_system_id,
		data_type_id
	)
	VALUES
	(
		2,
		4043
	)
END
