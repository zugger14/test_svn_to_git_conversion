IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211300)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call,file_path)
	VALUES (10211300, 'Maintain Non Standard Contract', 'Maintain Non Standard Contract', 10210000, 'windowNonStandardContract','_contract_administration/maintain_contract_group/maintain.contract.php')
 	PRINT ' Inserted 10211300 - Maintain Non Standard Contract.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211300 - Maintain Non Standard Contract already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211400)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call,file_path)
	VALUES (10211400, 'Maintain Transportation Contract', 'Maintain Transportation Contract', 10210000, 'windowTransportationContract','_contract_administration/maintain_contract_group/maintain.contract.transportation.php')
 	PRINT ' Inserted 10211400 - Maintain Transportation Contract.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211400 - Maintain Transportation Contract.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211212)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211212, 'Copy Maintain Contract', 'Copy Maintain Contract', 10211200, NULL)
 	PRINT ' Inserted 10211212 - Copy Maintain Contract.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211212 - Copy Maintain Contract.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211213)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211213, 'Document Maintain Contract', 'Document Maintain Contract', 10211200, NULL)
 	PRINT ' Inserted 10211213 - Document Maintain Contract.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211213 - Document Maintain Contract.'
END

IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211022)
BEGIN
	UPDATE application_functions 
	set function_name='Contract Charge Type UI',
	function_desc='Contract Charge Type UI',
	function_call=NULL
	WHERE function_id = 10211022
 	PRINT ' Updatedd 10211022 - Contract Charge Type UI.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211026)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211026, 'Contract Charge Type Delete', 'Contract Charge Type Delete', 10211000, NULL)
 	PRINT ' Inserted 10211026 - Contract Charge Type Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211026 - Contract Charge Type Delete.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211027)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211027, 'Contract Formula UI', 'Contract Formula UI', 10211000, NULL)
 	PRINT ' Inserted 10211027 - Contract Formula UI.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211027 - Contract Formula UI.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211028)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211028, 'Contract Formula Delete', 'Contract Formula Delete', 10211000, NULL)
 	PRINT ' Inserted 10211028 - Contract Formula Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211028 - Contract Formula Delete.'
END

