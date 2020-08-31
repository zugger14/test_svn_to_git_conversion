UPDATE static_data_type
SET  [internal] = 0, 
	[is_active] = 1
	WHERE [type_id] = 15000
PRINT 'Updated static data type 15000 - Tier Type.'