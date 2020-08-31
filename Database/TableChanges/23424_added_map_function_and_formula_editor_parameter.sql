IF NOT EXISTS (SELECT 1 FROM map_function_category WHERE function_name = 'GetWACOGPoolPrice') 
BEGIN 
	INSERT INTO map_function_category(category_id, function_name, is_active) 
	VALUES (27403, 'GetWACOGPoolPrice', 1) 
END 

IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE function_name = 'GetWACOGPoolPrice' AND field_label = 'WACOG Group ID') 
BEGIN 
	INSERT INTO formula_editor_parameter (function_name, 
		field_label, 
		field_type, 
		default_value, 
		tooltip, 
		field_size, 
		sql_string, 
		is_required, 
		is_numeric, 
		custom_validation, 
		sequence, 
		create_user, 
		create_ts, 
		blank_option) 
	VALUES ('GetWACOGPoolPrice', 'WACOG Group ID', 'd', NULL,  'WACOG Group ID',0,'SELECT wacog_group_id AS [Value], wacog_group_name AS [Label] FROM wacog_group','1','1',NULL,'1','farrms_admin', GETDATE(), 1) 
END 
ELSE  
BEGIN 
	Print 'Formula already exists - GETDATE().'
END 