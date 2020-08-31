IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10222000)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10222000, 'SAP Settlement Export', 'SAP Settlement Export', 10220000, 'windowSAPSettlementExport')
 	PRINT ' Inserted 10222000 - SAP Settlement Export.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10222000 - SAP Settlement Export already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10222010)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10222010, 'Post SAP Export', 'Post SAP Export', 10222000, '')
 	PRINT ' Inserted 10222010 - Post SAP Export.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10222010 - Post SAP Export already EXISTS.'
END


