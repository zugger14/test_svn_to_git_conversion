If exists (select 1 from application_functions where function_id = 10104800)
Begin
Update
application_functions set
function_name = 'Import/Export',
function_desc = 'Data Import/Export  ',
func_ref_id = NULL
where function_id = 10104800
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10104800,'Import/Export','Data Import/Export ',NULL, NULL);
END


If exists (select 1 from application_functions where function_id = 10104810)
Begin
Update
application_functions set
function_name = 'Add/Save',
function_desc = 'Add/Save',
func_ref_id = 10106300
where function_id = 10104810
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10104810,'Add/Save','Add/Save',10106300, NULL);
END

If exists (select 1 from application_functions where function_id = 10104811)
Begin
Update
application_functions set
function_name = 'Delete',
function_desc = 'Delete',
func_ref_id = 10106300
where function_id = 10104811
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10104811,'Delete','Delete',10106300, NULL);
END

If exists (select 1 from application_functions where function_id = 10104812)
Begin
Update
application_functions set
function_name = 'Run',
function_desc = 'Run',
func_ref_id = 10106300
where function_id = 10104812
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10104812,'Run','Run',10106300, NULL);
END

If exists (select 1 from application_functions where function_id = 10104813)
Begin
Update
application_functions set
function_name = 'Privilege',
function_desc = 'Privilege Data Import/Export',
func_ref_id = 10106300
where function_id = 10104813
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10104813,'Privilege','Privilege Data Import/Export',10106300, NULL);
END
