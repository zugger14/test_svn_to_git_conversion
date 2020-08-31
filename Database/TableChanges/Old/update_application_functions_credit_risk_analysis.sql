If exists (select 1 from application_functions where function_id = 10101128)
Begin
Update
application_functions set
function_name = 'Limit',
function_desc = 'Limit Tab',
func_ref_id = 10101122
where function_id = 10101128
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10101128,'Limit','Limit Tab',10101122);
END

If exists (select 1 from application_functions where function_id = 10101125)
Begin
Update
application_functions set
function_name = 'Enhancements',
function_desc = 'Counterparty Credit Info - Enhancements',
func_ref_id = 10101122
where function_id = 10101125
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10101125,'Enhancements','Counterparty Credit Info - Enhancements',10101122);
END

If exists (select 1 from application_functions where function_id = 10101123)
Begin
Update
application_functions set
function_name = 'Save',
function_desc = 'Counterparty Credit Info - Add/Edit',
func_ref_id = 10101122
where function_id = 10101123
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10101123,'Save','Counterparty Credit Info - Add/Edit',10101122);
END

If exists (select 1 from application_functions where function_id = 10101126)
Begin
Update
application_functions set
function_name = 'Add/Save',
function_desc = 'Enhancement Tab IU',
func_ref_id = 10101125
where function_id = 10101126
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10101126,'Add/Save','Enhancement Tab IU',10101125);
END

If exists (select 1 from application_functions where function_id = 10101127)
Begin
Update
application_functions set
function_name = 'Delete',
function_desc = 'Delete Enhancement Tab',
func_ref_id = 10101125
where function_id = 10101127
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10101127,'Delete','Delete Enhancement Tab',10101125);
END

If exists (select 1 from application_functions where function_id = 10101130)
Begin
Update
application_functions set
function_name = 'Add/Save',
function_desc = 'Add/Save',
func_ref_id = 10101128
where function_id = 10101130
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10101130,'Add/Save','Add/Save',10101128);
END

If exists (select 1 from application_functions where function_id = 10101131)
Begin
Update
application_functions set
function_name = 'Delete',
function_desc = 'Delete Limit',
func_ref_id = 10101128
where function_id = 10101131
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10101131,'Delete','Delete Limit',10101128);
END


If exists (select 1 from application_functions where function_id = 10192200)
Begin
Update
application_functions set
function_name = 'Calculate Credit Value Adjustment',
function_desc = 'Calculate Credit Value Adjustment',
func_ref_id = NULL
where function_id = 10192200
End
Else
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10192200,'Calculate Credit Value Adjustment','Calculate Credit Value Adjustment',NULL);
END


IF EXISTS(select 1 from setup_menu where function_id = 10101122 and product_category = 10000000)
Begin
	Update setup_menu
	set
	menu_type = 0
	where
	function_id = 10101122
	AND product_category = 10000000
End