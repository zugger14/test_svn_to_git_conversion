IF EXISTS (SELECT * FROM application_functions WHERE function_id = 10234100)
BEGIN
	UPDATE application_functions 
	SET
	file_path = '_accounting/derivative/transaction_processing/reclassify_dedes_values/reclassify.dedes.values.php'
	WHERE
	function_id = 10234100
END
ELSE 
	PRINT 'Function_id  does not exits.'
	
	
IF EXISTS (SELECT * FROM application_functions WHERE function_id = 10234600)
BEGIN
	UPDATE application_functions 
	SET
	file_path = '_accounting/derivative/transaction_processing/first_day_gain_loss/first.day.gain.loss.php'
	WHERE
	function_id = 10234600
END
ELSE 
	PRINT 'Function_id  does not exits.'


	
IF EXISTS (SELECT * FROM application_functions WHERE function_id = 10237300)
BEGIN
	UPDATE application_functions 
	SET
	file_path = '_accounting/derivative/transaction_processing/des_of_a_hedge/view.link.php?mode=r&function_id=10237300'
	WHERE
	function_id = 10237300
END
ELSE 
	PRINT 'Function_id  does not exits.'
	
	
IF EXISTS (SELECT * FROM application_functions WHERE function_id = 10233000)
BEGIN
	UPDATE application_functions 
	SET
	file_path = '_accounting/derivative/transaction_processing/_etrm_interfeces/delete.voided.deals.php'
	WHERE
	function_id = 10233000
END
ELSE 
	PRINT 'Function_id  does not exits.'

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234100)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10234100, 'Amortize Deferred AOCI', 'Amortize Deferred AOCI', 10230000, 'windowAmortizeLockedAOCI', '_accounting/derivative/transaction_processing/amortize_locked_aoci/amortize.locked.aoci.php')
 	PRINT ' Inserted 10234100 - Amortize Deferred AOCI.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234100 - Amortize Deferred AOCI already EXISTS.'
END