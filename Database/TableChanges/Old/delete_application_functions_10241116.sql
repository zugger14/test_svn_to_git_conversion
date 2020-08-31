IF EXISTS( SELECT 1 FROM   application_functions WHERE  function_id = 10241116 AND func_ref_id = 10241100)
BEGIN
	DELETE FROM application_functional_users WHERE function_id = 10241116
    DELETE FROM application_functions WHERE  function_id = 10241116 AND func_ref_id = 10241100
END