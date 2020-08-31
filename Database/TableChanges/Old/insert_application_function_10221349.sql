IF EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 10221349)
	PRINT 'Post'
ELSE
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10221349,'Post','Post SAP Export',10221348, NULL);
END



IF NOT EXISTS (
	SELECT 1 from setup_menu WHERE window_name = 'windowsSAPExport' AND function_id = 10221348
)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		default_parameter,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order,
		menu_type
	)
	VALUES(
		'10221348',
		'windowsSAPExport',
		'GL Entries Export',
		NULL,
		0,
		10221300,
		10000000,
		111,
		0
	)
END