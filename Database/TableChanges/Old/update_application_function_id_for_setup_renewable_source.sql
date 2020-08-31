UPDATE application_functions 
SET book_required = 1 
WHERE function_id = 12101700

UPDATE application_ui_template_definition 
SET application_function_id = 12101700 
WHERE application_function_id = 12101701

UPDATE application_ui_template 
SET application_function_id = 12101700 
WHERE application_function_id = 12101701