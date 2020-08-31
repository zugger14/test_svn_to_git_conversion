UPDATE static_data_type
SET [type_name] = 'Organization Type',
	[description] = 'Organization Type',
	internal = 0
	WHERE [type_id] = 10020
PRINT 'Updated static data type 10020 - Organization Type.'