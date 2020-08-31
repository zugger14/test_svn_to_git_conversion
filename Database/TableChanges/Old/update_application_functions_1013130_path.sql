IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131300)
BEGIN
	UPDATE application_functions
	SET file_path = '_accounting/derivative/deal_capture/import_data/import.data.php?call_from=d'
	WHERE function_id = 10131300
END