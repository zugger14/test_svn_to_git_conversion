--Insert Report Category
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 10008)
	INSERT INTO static_data_type
	(
		[type_id],
		[type_name],
		internal,
		[description]	
	)
	VALUES
	(
		
		10008,
		'Report Category',
		1,
		'Report Category'
	)
	

	
--Insert Report Writer
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201000)		
	INSERT INTO application_functions
	(
		function_id,
		function_name,
		function_desc,
		func_ref_id
	)
	
	
	VALUES
	(
		10201000, 
		'Report Writer',
		'Report Writer',
		10200000 --Reporting
	)
	
	

	
--Insert Report Writer Views
IF NOT EXISTS(SELECT * FROM application_functions WHERE function_id = 10201012)		
	INSERT INTO application_functions
	(
		function_id,
		function_name,
		function_desc,
		func_ref_id
	)
	VALUES
	(
		10201012,
		'Report Writer View',
		'Report Writer View',
		10201000 --Report Writer
	)