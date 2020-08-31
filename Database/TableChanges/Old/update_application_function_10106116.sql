If exists (select 1 from application_functions where function_id = 10106116)
Begin
Update
application_functions set
function_name = 'Add/Save',
function_desc = 'Add/Save',
func_ref_id = 10106115
where function_id = 10106116
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10106116,'Add/Save','Add/Save',10106115);
END
