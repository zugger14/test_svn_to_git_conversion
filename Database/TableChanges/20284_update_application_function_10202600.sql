IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10202600)
BEGIN
UPDATE application_functions
SET func_ref_id = 10200000
WHERE function_id = 10202600
END
PRINT 'Application Function 10202600 Updated.'