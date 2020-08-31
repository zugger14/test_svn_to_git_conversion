--func_ref_id is set to NULL if function_id id not necessary for privilege
UPDATE application_functions
SET func_ref_id = NULL
WHERE function_id in(
	10101216,
	10101217,
	10101213)