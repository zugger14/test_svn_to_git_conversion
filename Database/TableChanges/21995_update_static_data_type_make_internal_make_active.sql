/*
	# Set 'Source Book Group1' as External Static Data
*/
UPDATE static_data_type
SET internal = 0
WHERE type_name = 'Source Book Group1'

UPDATE static_data_type
SET internal = 0
WHERE type_name = 'Source Book Group2'

UPDATE static_data_type
SET internal = 0
WHERE type_name = 'Source Book Group3'

UPDATE static_data_type
SET internal = 0
WHERE type_name = 'Source Book Group4'

/*
	# Set 'Product Group' as Active External Static Data
*/
UPDATE static_data_type
SET is_active = 1
WHERE [type_name] = 'Product Group'

GO