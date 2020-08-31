IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104800)
BEGIN
UPDATE application_functions
SET function_name='Setup Import/Export'
WHERE function_id = 10104800
END