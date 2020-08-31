If exists (select 1 from application_functions where function_id = 10105803)
Begin
Update
application_functions set
function_name = 'Fees',
function_desc = 'Fees Counterparty',
func_ref_id = 10105800
where function_id = 10105803
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10105803,'Fees','Fees Counterparty',10105800, NULL);
END

If exists (select 1 from application_functions where function_id = 10105804)
Begin
Update
application_functions set
function_name = 'Add/Save',
function_desc = 'Add/Save Fees Counterparty',
func_ref_id = 10105803
where function_id = 10105804
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10105804,'Add/Save','Add/Save Fees Counterparty',10105803, NULL);
END

If exists (select 1 from application_functions where function_id = 10105805)
Begin
Update
application_functions set
function_name = 'Delete',
function_desc = 'Delete Fees Counterparty',
func_ref_id = 10105803
where function_id = 10105805
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10105805,'Delete','Delete Fees Counterparty',10105803, NULL);
END

If exists (select 1 from application_functions where function_id = 10105894)
Begin
Update
application_functions set
function_name = 'Meter Mapping Add/Save/Delete',
function_desc = 'Meter Mapping Add/Save/Delete',
func_ref_id = 10105895
where function_id = 10105894
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10105894,'Meter Mapping Add/Save/Delete','Meter Mapping Add/Save/Delete',10105895, NULL);
END
