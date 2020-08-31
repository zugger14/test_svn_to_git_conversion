IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233000)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10233000, 'Delete Voided Deal', 'Delete Voided Deal', 10230000, 'windowVoidDealImports')
 	PRINT ' Inserted 10233000 - Delete Voided Deal.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233000 - Delete Voided Deal already EXISTS.'
END


--select * from application_functions where function_id = 10233000
--update application_functions set file_path = '_accounting/derivative/transaction_processing/_etrm_interfeces/delete.voided.deals.php'  where function_id = 10233000

