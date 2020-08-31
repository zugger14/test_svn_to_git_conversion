If exists (select 1 from application_functions where function_id = 10183410)
Begin
Update
application_functions set
function_name = 'Add/Save',
function_desc = 'Setup What if Criteria IU',
func_ref_id = 10183400
where function_id = 10183410
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10183410,'Add/Save','Setup What if Criteria IU',10183400);
END


If exists (select 1 from application_functions where function_id = 10183411)
Begin
Update
application_functions set
function_name = 'Delete',
function_desc = 'Delete Setup What if Criteria',
func_ref_id = 10183400
where function_id = 10183411
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10183411,'Delete','Delete Setup What if Criteria',10183400);
END


If exists (select 1 from application_functions where function_id = 10183412)
Begin
Update
application_functions set
function_name = 'Run',
function_desc = 'Run Setup What if Criteria',
func_ref_id = 10183400
where function_id = 10183412
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10183412,'Delete','Run Setup What if Criteria',10183400);
END

If exists (select 1 from application_functions where function_id = 10183413)
Begin
Update
application_functions set
function_name = 'Hypothetical',
function_desc = 'Hypothetical Setup What if Criteria',
func_ref_id = 10183400
where function_id = 10183413
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10183413,'Hypothetical','Hypothetical Setup What if Criteria',10183400);
END

If exists (select 1 from application_functions where function_id = 10183414)
Begin
Update
application_functions set
function_name = 'Add/save',
function_desc = 'Hypothetical Add/save',
func_ref_id = 10183413
where function_id = 10183414
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10183414,'Add/save','Hypothetical Add/save',10183413);
END

If exists (select 1 from application_functions where function_id = 10183415)
Begin
Update
application_functions set
function_name = 'Delete',
function_desc = 'Hypothetical Delete',
func_ref_id = 10183413
where function_id = 10183415
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10183415,'Delete','Hypothetical Delete',10183415);
END




