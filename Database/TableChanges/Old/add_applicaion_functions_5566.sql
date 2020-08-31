IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103300)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103300, 'Maintain Contract Components Gl Codes', 'Maintain Contract Components Gl Codes', 10100000, 'windowDefineInvoiceGLCode')
 	PRINT ' Inserted 10103300 - Maintain Contract Components Gl Codes.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103300 - Maintain Contract Components Gl Codes already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103310)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103310, 'Contract Components GL Codes IU', 'Contract Components GL Codes IU', 10103300, 'windowDefineInvoiceGLCodeIU')
 	PRINT ' Inserted 10103310 - Contract Components GL Codes IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103310 - Contract Components GL Codes IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103311)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103311, 'Delete Contract Components Gl Codes', 'Delete Contract Components Gl Codes', 10103300, NULL)
 	PRINT ' Inserted 10103311 - Delete Contract Components Gl Codes.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103311 - Delete Contract Components Gl Codes already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103312)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103312, 'Contract Components GL Codes Detail IU', 'Contract Components GL Codes Detail IU', 10103300, 'windowDefineInvoiceGLCodeIU')
 	PRINT ' Inserted 10103312 - Contract Components GL Codes Detail IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103312 - Contract Components GL Codes Detail IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103313)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103313, 'Delete Contract Components GL Codes Detail', 'Delete Contract Components GL Codes Detail', 10103300, NULL)
 	PRINT ' Inserted 10103313 - Delete Contract Components GL Codes Detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103313 - Delete Contract Components GL Codes Detail already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103400)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103400, 'Setup Default GL Code for Contract Components', 'Setup Default GL Code for Contract Components', 10100000, 'windowSetupDefaultGLCode')
 	PRINT ' Inserted 10103400 - Setup Default GL Code for Contract Components.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103400 - Setup Default GL Code for Contract Components already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103410)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103410, 'Setup Default GL Code for Contract Components IU', 'Setup Default GL Code for Contract Components IU', 10103400, 'windowSetupDefaultGLCodeIU')
 	PRINT ' Inserted 10103410 - Setup Default GL Code for Contract Components IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103410 - Setup Default GL Code for Contract Components IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103411)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103411, 'Delete Default GL Code for Contract Components', 'Delete Default GL Code for Contract Components', 10103400, NULL)
 	PRINT ' Inserted 10103411 - Delete Default GL Code for Contract Components.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103411 - Delete Default GL Code for Contract Components already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10151200)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10151200, 'Run Import Audit Report', 'Run Import Audit Report', 10150000, 'windowRunFilesImportAuditReport')
 	PRINT ' Inserted 10151200 - Run Import Audit Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10151200 - Run Import Audit Report already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103500)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103500, 'Setup Hedging Relationship Types', 'Setup Hedging Relationship Types', 10100000, 'windowSetupHedgingRelationshipsTypes')
 	PRINT ' Inserted 10103500 - Setup Hedging Relationship Types.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103500 - Setup Hedging Relationship Types already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103510)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103510, 'Setup Hedging Relationship Types IU', 'Setup Hedging Relationship Types IU', 10103500, 'windowSetupHedgingRelationshipsTypesDetail')
 	PRINT ' Inserted 10103510 - Setup Hedging Relationship Types IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103510 - Setup Hedging Relationship Types IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103511)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103511, 'Copy Hedging Relationship Types', 'Copy Hedging Relationship Types', 10103500, NULL)
 	PRINT ' Inserted 10103511 - Copy Hedging Relationship Types.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103511 - Copy Hedging Relationship Types already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103512)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103512, 'Delete Setup Hedging Relationship Types', 'Delete Setup Hedging Relationship Types', 10103500, NULL)
 	PRINT ' Inserted 10103512 - Delete Setup Hedging Relationship Types.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103512 - Delete Setup Hedging Relationship Types already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103516)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103516, 'Approve Setup Hedging Relationship Types', 'Approve Setup Hedging Relationship Types', 10103500, NULL)
 	PRINT ' Inserted 10103516 - Approve Setup Hedging Relationship Types.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103516 - Approve Setup Hedging Relationship Types already EXISTS.'
END

