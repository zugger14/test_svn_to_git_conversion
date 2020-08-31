IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106300)
BEGIN
UPDATE application_functions
SET func_ref_id='10100000',
function_name='Run Data Import/Export'
WHERE function_id = 10106300
END