UPDATE  application_functions SET function_name = 'View' , function_desc = 'View'  WHERE function_id = 10165000
UPDATE  application_functions SET function_name = 'Add/Save' , function_desc = 'Add/Save' WHERE function_id = 10165010
UPDATE  application_functions SET function_name = 'Delete' , function_desc = 'Delete' WHERE function_id = 10165011

SELECT * FROM application_functions WHERE function_id = 10165000
SELECT * FROM application_functions WHERE function_id = 10165010
SELECT * FROM application_functions WHERE function_id = 10165011
