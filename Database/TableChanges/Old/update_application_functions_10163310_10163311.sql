If exists (select 1 from application_functions where function_id = 10163310)
Begin
Update
application_functions set
function_name = 'Add/Save',
function_desc = 'Add/Save',
func_ref_id = 10163300
where function_id = 10163310
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10163310,'Add/Save','Add/Save',10163300);
END

If exists (select 1 from application_functions where function_id = 10163311)
Begin
Update
application_functions set
function_name = 'Delete',
function_desc = 'Delete',
func_ref_id = 10163300
where function_id = 10163311
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10163311,'Delete','Delete',10163300);
END
