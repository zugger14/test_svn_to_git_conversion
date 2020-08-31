If exists (select 1 from application_functions where function_id = 10104600)
Begin
Update
application_functions set
function_name = 'Setup Settlement Netting Group',
function_desc = 'Setup Settlement Netting Group',
func_ref_id = 10100000
where function_id = 10104600
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10104600,'Setup Settlement Netting Group','Setup Settlement Netting Group',10100000);
END

If exists (select 1 from application_functions where function_id = 10104610)
Begin
Update
application_functions set
function_name = 'Add/Save',
function_desc = 'Add/Save',
func_ref_id = 10104600
where function_id = 10104610
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10104610,'Add/Save','Add/Save',10104600);
END

If exists (select 1 from application_functions where function_id = 10104611)
Begin
Update
application_functions set
function_name = 'Delete',
function_desc = 'Delete',
func_ref_id = 10104600
where function_id = 10104611
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10104611,'Delete','Delete',10104600);
END
