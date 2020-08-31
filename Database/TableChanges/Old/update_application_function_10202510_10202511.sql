IF EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10202510)
BEGIN
UPDATE
	application_functions SET
	function_name = 'Add/Save',
	function_desc = 'Add/Save',
	func_ref_id = 10202500
WHERE function_id = 10202510
END
ELSE
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10202510,'Add/Save','Add/Save',10202500)
END

IF EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10202511)
BEGIN
UPDATE
	application_functions SET
	function_name = 'Delete',
	function_desc = 'Delete Report Manager DHX',
	func_ref_id = 10202500
WHERE function_id = 10202511
END
ELSE
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10202511,'Delete','Delete Report Manager DHX',10202500)
END
