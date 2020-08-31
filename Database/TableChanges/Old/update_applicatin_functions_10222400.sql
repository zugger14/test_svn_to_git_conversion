If exists(select 1 from application_functions where function_id = 10222400 and function_name = 'Run Meter Data Report')
Begin
Update application_functions
set
function_name = 'Meter Data Report'
where 
function_id = 10222400
End