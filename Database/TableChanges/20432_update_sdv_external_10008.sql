UPDATE static_data_type
SET 
	[internal] = 0, 
	[is_active] = 1
	WHERE [type_id] = 10008
PRINT 'Updated static data type 10008 - Report Category.'