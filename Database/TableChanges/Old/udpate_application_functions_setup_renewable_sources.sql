UPDATE application_functions
SET function_name = 'Assignment'
WHERE function_id = 12101720

UPDATE application_functions
SET func_ref_id = 12101720
WHERE function_id = 12101721

UPDATE application_functions
SET func_ref_id = 12100000
WHERE function_id = 12101701

UPDATE application_functions
SET function_name = 'Add/Save/Copy'
WHERE function_id = 12101710

UPDATE application_functions
SET function_name = 'Delete'
WHERE function_id = 12101711

UPDATE application_functions
SET function_name = 'Add/Save'
WHERE function_id = 12101713

UPDATE application_functions
SET function_name = 'Delete'
WHERE function_id = 12101714

UPDATE application_functions
SET function_name = 'Add/Save',
    function_desc = 'Assignment Form Details'
WHERE function_id = 12101721

UPDATE application_functions
SET function_name = 'Delete'
WHERE function_id = 12101722

DELETE FROM application_functions
WHERE function_id IN (12101725, 12101726)