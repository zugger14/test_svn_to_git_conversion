Update application_functions 
set
function_call = 'windowVirtualGas'
where
function_id = 10162300


Update application_functions 
set
function_call = 'WindowDefineUOMConversion'
where
function_id = 10101182

Update setup_menu
set
window_name = 'windowReportTemplateSetup'
where
function_id = 10211213

Update application_functions 
set
function_call = 'windowSetupTimeSeries'
where
function_id = 10106100

If exists (SELECT 1 FROM setup_menu WHERE setup_menu_id =196 and window_name = 'windowDefineMeterID' and function_id = 10103000)
BEGIN
DELETE FROM setup_menu WHERE setup_menu_id = 196
END

