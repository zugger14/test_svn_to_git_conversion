/*
	# Script to update type name as 'Product Group' from 'Internal Portfolio'
*/
UPDATE static_data_type
SET [type_name] = 'Product Group'
WHERE [type_name] = 'Internal Portfolio' AND [type_id] = 39800

GO