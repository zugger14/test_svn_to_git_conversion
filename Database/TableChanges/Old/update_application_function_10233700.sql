IF EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10233700)
BEGIN
	UPDATE application_functions 
	SET file_path = '_accounting/derivative/transaction_processing/des_of_a_hedge/view.link.php? function_id=10233700'
	WHERE function_id = 10233700
END