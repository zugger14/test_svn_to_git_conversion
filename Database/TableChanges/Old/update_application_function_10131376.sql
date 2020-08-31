IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131376)
BEGIN
	UPDATE application_functions SET function_desc = 'Curve Correlation' WHERE function_id = 10131376
END