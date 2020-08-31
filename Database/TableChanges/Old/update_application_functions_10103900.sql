IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10103900)
UPDATE application_functions SET function_call = 'windowSetupFieldTemplate' WHERE function_id = 10103900