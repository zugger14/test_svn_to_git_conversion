IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103120)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10103120, 'Term Mapping Staging', 'Term Mapping Staging', 10103100, NULL)
 	PRINT ' Inserted 10103120 - Term Mapping Staging.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103120 - Term Mapping Staging already EXISTS.'
END

--added the function id=10161610 for bid offer header
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10161610)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10161610, 'Bid Offer Header', 'Bid Offer Header', 10160000, 'windowBidOfferFormulatorHeaderIU')
 	PRINT ' Inserted 10161610 - Bid Offer Header.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10161610 - Bid Offer Header already EXISTS.'
END

--added the function id = 10161612 for bid offer detail
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10161612)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10161612, 'Bid Offer Detail', 'Bid Offer Detail', 10160000, 'windowBidOfferFormulatorDetailIU')
 	PRINT ' Inserted 10161612 - Bid Offer Detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10161612 - Bid Offer Detail already EXISTS.'
END


