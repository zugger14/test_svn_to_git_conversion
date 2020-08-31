IF NOT EXISTS(SELECT 'X' FROM external_source_import where data_type_id = 4046)
BEGIN
	INSERT INTO external_source_import (source_system_id, data_type_id)
	VALUES (2,4046)
END 