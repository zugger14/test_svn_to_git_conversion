IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10162500)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10162500, 'Run Inventory Calc', 'Run Inventory Calc', 10160000, 'windowRunInventoryCalc')
 	PRINT ' Inserted 10162500 - Run Inventory Calc.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10162500 - Run Inventory Calc already EXISTS.'
END
