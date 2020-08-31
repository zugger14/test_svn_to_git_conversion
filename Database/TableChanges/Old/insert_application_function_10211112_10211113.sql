IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211112)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211112, 'Contract Charge Type Templates Detail IU', 'Contract Charge Type Templates Detail IU', 10211110, 'windowContractChargeTypeIU')
 	PRINT ' Inserted 10211112 - Contract Charge Type Templates Detail IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211112 - Contract Charge Type Templates Detail IU already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211113)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211113, 'Contract Charge Type Templates Detail Delete', 'Contract Charge Type Templates Detail Delete', 10211110, NULL)
 	PRINT ' Inserted 10211113 - Contract Charge Type Templates Detail Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211113 - Contract Charge Type Templates Detail Delete already EXISTS.'
END	
	
