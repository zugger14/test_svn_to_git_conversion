IF Exists (Select 1 from application_functions where function_id =10183412)
Begin
update application_functions
set function_name = 'Run'
where
function_id = 10183412
End

IF Exists (Select 1 from application_functions where function_id =10183415)
Begin
update application_functions
set func_ref_id  = 10183413
where
function_id = 10183415
End

IF Exists (Select 1 from application_functions where function_id =10183414)
Begin
update application_functions
set function_name = 'Add/Save'
where
function_id = 10183414
End