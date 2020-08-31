UPDATE adiha_default_codes_values_possible 
SET [var_value] = '2'
	, [description] = 'Run in parallel'
WHERE default_code_id = 203 
AND var_value = '1'


UPDATE adiha_default_codes_values_possible 
SET [var_value] = '1'
	, [description] = 'Run in queue'
WHERE default_code_id = 203 
AND var_value = '0' 


UPDATE adiha_default_codes_values_possible 
SET [var_value] = '0'
	, [description] = 'Run in parallel'
WHERE default_code_id = 203 
AND var_value = '2' 
