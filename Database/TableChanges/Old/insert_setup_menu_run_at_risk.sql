
IF NOT EXISTS(SELECT 1 FROM setup_menu where function_id = 10181299 and product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id,	window_name,	display_name,	default_parameter,	hide_show,	parent_menu_id,	product_category,	menu_order,	menu_type)
	SELECT 10181299,	NULL,	'Run At Risk',	NULL,	1,	10180000,	10000000,	140,	1
END

IF NOT EXISTS(SELECT 1 FROM setup_menu where function_id = 10181200 and product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id,	window_name,	display_name,	default_parameter,	hide_show,	parent_menu_id,	product_category,	menu_order,	menu_type)
	SELECT 10181200,	'RunAtRiskMeasurement',	'Run At Risk Measurement',	NULL,	1,	10181299,	10000000,	8,	0
END

IF NOT EXISTS(SELECT 1 FROM application_functions where function_id = 10181200)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	SELECT 10181200, 'Run At Risk Measurement', 'Run At Risk Measurement', 10181299, 'RunAtRiskMeasurement','_valuation_risk_analysis/run_at_risk/run.risk.measurement.php'
END

IF NOT EXISTS(SELECT 1 FROM application_functions where function_id = 10181210)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,	func_ref_id	,requires_at,	document_path,	function_call,	function_parameter)
	SELECT 10181210,'Run At Risk Measurement IU',	'Run At Risk Measurement IU',	10181200,	NULL,	NULL,	NULL, NULL
END

IF NOT EXISTS(SELECT 1 FROM application_functions where function_id = 10181212)
BEGIN
	INSERT INTO application_functions(function_id,	function_name,	function_desc,	func_ref_id,	requires_at,	document_path,	function_call,	function_parameter)
	SELECT 10181212,	'Delete Run At Risk Measurement',	'Delete Run At Risk Measurement',	10181200,	NULL,	NULL,	NULL,	NULL
END