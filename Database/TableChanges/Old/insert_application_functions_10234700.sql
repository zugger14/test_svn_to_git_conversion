IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10234700)
BEGIN
	INSERT INTO application_functions 
	(
		function_id,
		function_name,
		function_desc,
		func_ref_id,
		function_call,
		file_path,
		book_required
	)
	VALUES
	(
		10234700,
		'Maintain Deal Transfer',
		'Maintain Deal Transfer',
		10130000,
		'windowMaintainDealTransfer',
		'_accounting/derivative/transaction_processing/maintain_deal_transfer/maintain.deal.transfer.main.php',
		0	
	)

	PRINT 'Maintain Deal Transfer inserted.'
END
ELSE 
BEGIN
	PRINT 'Maintain Deal Transfer already exist'
END