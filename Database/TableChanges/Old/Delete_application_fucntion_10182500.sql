IF EXISTS(SELECT 1 FROM application_functional_users WHERE function_id = 10182500 AND functional_users_id IN(20981, 20313) )
	DELETE FROM application_functional_users WHERE function_id = 10182500 AND functional_users_id IN(20981, 20313) 

IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182500 AND func_ref_id =10182300)
	DELETE FROM application_functions WHERE function_id = 10182500 AND func_ref_id =10182300
	
	
