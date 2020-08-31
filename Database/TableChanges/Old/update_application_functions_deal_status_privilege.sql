If exists (select 1 from application_functions where function_id = 10104000)
Begin
Update
application_functions set
function_name = 'Define Deal Status Privilege',
function_desc = 'Define Deal Status Privilege',
func_ref_id = NULL
where function_id = 10104000
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10104000,'Define Deal Status Privilege','Define Deal Status Privilege',NULL, NULL);
END


If exists (select 1 from application_functions where function_id = 10104010)
Begin
Update
application_functions set
function_name = 'Add/Save/Delete',
function_desc = 'Add/Save/Delete',
func_ref_id = 10104000
where function_id = 10104010
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10104010,'Add/Save/Delete','Add/Save/Delete',10104000, NULL);
END

If exists (select 1 from application_functions where function_id = 10104011)
Begin
Update
application_functions set
function_name = 'Privilege',
function_desc = 'deal status Privilege',
func_ref_id = 10104000
where function_id = 10104011
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10104011,'Privilege','deal status Privilege',10104000, NULL);
END
