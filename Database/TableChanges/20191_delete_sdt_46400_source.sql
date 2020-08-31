DELETE sdv FROM static_data_value sdv 
	INNER JOIN static_data_type sdt ON sdt.type_id = sdv.type_id 
WHERE sdt.type_id = 46400 AND sdt.type_name = 'Source'

DELETE FROM static_data_type WHERE type_id = 46400 AND TYPE_NAME = 'Source' -- Deleting type id 46400