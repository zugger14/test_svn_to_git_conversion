IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234700)
BEGIN
	UPDATE application_functions 
	SET file_path = '_accounting/derivative/transaction_processing/maintain_deal_transfer/maintain.deal.transfer.php' 
	WHERE function_id = 10234700
END