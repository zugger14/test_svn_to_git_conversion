--Remove privilege from roles and users
DELETE FROM application_functional_users 
WHERE function_id = 10202614

--Delete function id
DELETE FROM application_functions 
WHERE function_id = 10202614
	AND func_ref_id = 10202600