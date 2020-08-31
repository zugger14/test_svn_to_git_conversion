IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163710)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10163710, 'Bookout/Match', 'Bookout/Match', 10163700, 'windowBookoutMatch')
 	PRINT ' Inserted 10163710 - Bookout/Match.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163710 - Bookout/Match already EXISTS.'
END

GO

--unmatch
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163711)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id)
	VALUES (10163711, 'Delete', 'Delete', 10163700)
 	PRINT ' Inserted 10163711 - Bookout/Match.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163711 - Bookout/Match already EXISTS.'
END


--split unsplit
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163720)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10163720, 'Split/Unsplit', 'Split/Unsplit', 10163700, 'windowSplitUnsplit')
 	PRINT ' Inserted 10163720 - Split/Unsplit.'
END
ELSE
BEGIN
	UPDATE application_functions
	SET function_name = 'Split/Unsplit'
		, function_desc = 'Split/Unsplit'
		, func_ref_id = 10163700
		, function_call = 'windowSplitUnsplit'
	WHERE function_id = 10163720
	PRINT 'Application FunctionID 10163720 - Split/Unsplit already EXISTS.'
END

 

GO

---create deal
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163730)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10163730, 'Create Receipt Delivery Deal', 'Create Receipt Delivery Deal', 10163700, 'windowCreateReceiptDeliveryDeal')
 	PRINT ' Inserted 10163730 - Create Receipt Delivery Deal.'
END
ELSE
BEGIN
	UPDATE application_functions
	SET function_name = 'Create Receipt Delivery Deal'
		, function_desc = 'Create Receipt Delivery Deal'
		, func_ref_id = 10163700
		, function_call = 'windowCreateReceiptDeliveryDeal'
	WHERE function_id = 10163730
	PRINT 'Application FunctionID 10163730 - Create Receipt Delivery Deal already EXISTS.'
END


 

GO






