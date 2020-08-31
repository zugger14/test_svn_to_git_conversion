IF EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 10221349)
Begin
	Update application_functions
	set
	func_ref_id = 10202201,
	function_name = 'Post'
	where
	function_id = 10221349
END
ELSE
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10221349,'Post','Post SAP Export',10202201, NULL)
END

Update
setup_menu
set
menu_type = 0
where
display_name = 'Export GL Entries' AND function_id = 10202201
and product_category = 10000000
