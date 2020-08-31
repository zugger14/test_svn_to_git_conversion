If exists (select 1 from application_functions where function_id = 10122500)
Begin
Update
application_functions set
function_name = 'Setup Alerts',
func_ref_id = NULL
where function_id = 10122500
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10122500,'Setup Alerts','Setup Alerts',NULL, NULL);
END

If exists (select 1 from application_functions where function_id = 10122501)
Begin
Update
application_functions set
function_name = 'Conditions',
func_ref_id = 10122500
where function_id = 10122501
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10122501,'Conditions','Setup Alerts Conditions',10122500, NULL);
END

If exists (select 1 from application_functions where function_id = 10122502)
Begin
Update
application_functions set
function_name = 'Delete',
function_desc = 'Maintain Alerts Conditions Delete',
func_ref_id = 10122501
where function_id = 10122502
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10122502,'Conditions','Maintain Alerts Conditions Delete',10122501, NULL);
END

If exists (select 1 from application_functions where function_id = 10122503)
Begin
Update
application_functions set
function_name = 'Add/Save',
function_desc = 'Add/Save Alerts',
func_ref_id = 10122501
where function_id = 10122503
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10122503,'Add/Save','Add/Save Alerts',10122501, NULL);
END

If exists (select 1 from application_functions where function_id = 10122510)
Begin
Update
application_functions set
function_name = 'Add/Save',
function_desc = 'Maintain Alerts IU',
func_ref_id = 10122500
where function_id = 10122510
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10122510,'Add/Save','Maintain Alerts IU',10122500, NULL);
END

If exists (select 1 from application_functions where function_id = 10122511)
Begin
Update
application_functions set
function_name = 'Delete',
function_desc = 'Maintain Alerts Delete',
func_ref_id = 10122500
where function_id = 10122511
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10122511,'Delete','Maintain Alerts Delete',10122500, NULL);
END


If exists (select 1 from application_functions where function_id = 10122512)
Begin
Update
application_functions set
function_name = 'Relation',
function_desc = 'Relation Alerts',
func_ref_id = 10122500
where function_id = 10122512
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10122512,'Relation','Relation Alerts',10122500, NULL);
END

If exists (select 1 from application_functions where function_id = 10122513)
Begin
Update
application_functions set
function_name = 'Add/Save/Delete',
function_desc = 'Add/Save Relation Alerts',
func_ref_id = 10122512
where function_id = 10122513
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10122513,'Add/Save/Delete','Add/Save Relation Alerts',10122512, NULL);
END


If exists (select 1 from application_functions where function_id = 10122515)
Begin
Update
application_functions set
function_name = 'Action',
function_desc = 'Action',
func_ref_id = 10122500
where function_id = 10122515
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10122515,'Action','Action',10122500, NULL);
END


If exists (select 1 from application_functions where function_id = 10122516)
Begin
Update
application_functions set
function_name = 'Add/Save/Delete',
function_desc = 'Add/Save/Delete',
func_ref_id = 10122515
where function_id = 10122516
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10122516,'Add/Save/Delete','Add/Save/Delete Action',10122515, NULL);
END

If exists (select 1 from application_functions where function_id = 10122514)
Begin
Update
application_functions set
func_ref_id = NULL
where function_id = 10122514
End