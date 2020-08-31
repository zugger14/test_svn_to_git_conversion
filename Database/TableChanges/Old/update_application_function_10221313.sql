IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10221313 AND function_name like 'Export Invoice')
BEGIN
 Update
 application_functions
 SET
 func_ref_id  = NULL
 WHERE
 function_id = 10221313
END
