If exists (select 1 from application_functions where function_id = 10101910)
Begin
Update
application_functions set
function_name = 'Add/Save/Delete',
function_desc = 'Add/Save/Delete',
func_ref_id = 10101900
where function_id = 10101910
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10101910,'Add/Save/Delete','Add/Save/Delete',10101900);
END
