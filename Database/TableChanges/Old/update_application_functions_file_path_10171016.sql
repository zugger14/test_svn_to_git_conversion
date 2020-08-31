IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10171016)
BEGIN
	UPDATE application_functions 
	SET file_path = '_deal_capture/maintain_deals/generate.confirmation.php',
	function_name = 'Generate Confirmation',
	function_desc = 'Generate Confirmation' 
	WHERE function_id = 10171016
END
