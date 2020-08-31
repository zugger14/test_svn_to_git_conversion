UPDATE static_data_type
SET [type_name] = 'Profit Center',
	[description] = 'Profit Center',
	internal = 0
	WHERE [type_id] = 29900
PRINT 'Updated static data type 29900 - Profit Center.'