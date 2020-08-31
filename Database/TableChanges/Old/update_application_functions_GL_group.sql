If exists (select 1 from application_functions where function_id = 10103300)
Begin
Update
application_functions set
function_name = 'Setup GL Groups',
function_desc = 'Setup GL Groups',
func_ref_id = NULL
where function_id = 10103300
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10103300,'Setup GL Groups','Setup GL Groups',NULL, NULL);
END

If exists (select 1 from application_functions where function_id = 10103310)
Begin
Update
application_functions set
function_name = 'Add/Save',
function_desc = 'Add/Save',
func_ref_id = 10103300
where function_id = 10103310
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10103310,'Add/Save','Add/Save',10103300, NULL);
END

If exists (select 1 from application_functions where function_id = 10103311)
Begin
Update
application_functions set
function_name = 'Delete',
function_desc = 'Delete',
func_ref_id = 10103300
where function_id = 10103311
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10103311,'Delete','Delete',10103300, NULL);
END

If exists (select 1 from application_functions where function_id = 10103312)
Begin
Update
application_functions set
function_name = 'GL Group Detail',
function_desc = 'GL Group Detail',
func_ref_id = NULL
where function_id = 10103312
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10103312,'GL Group Detail','GL Group Detail',NULL, NULL);
END

