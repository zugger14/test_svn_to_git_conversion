IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20001200)
BEGIN
	UPDATE application_functions 
		SET file_path = '_setup/setup_fees/maintain.fees.php'
	WHERE function_id = 20001200
END
