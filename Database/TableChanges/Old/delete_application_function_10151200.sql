UPDATE application_functional_users
SET    function_id = 10201400
WHERE  function_id = 10151200

IF EXISTS(SELECT * FROM application_functions WHERE  function_name = 'Run Import Audit Report' AND func_ref_id = 10150000)
BEGIN
	DELETE FROM application_functions
	WHERE  function_name = 'Run Import Audit Report'
       AND func_ref_id = 10150000	
END

