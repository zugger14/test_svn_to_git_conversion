IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10162400)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10162400, 'Run Roll Forward Inventory Report', 'Run Roll Forward Inventory Report', 10160000, 'windowRunRollForwardInventoryReport')
 	PRINT ' Inserted 10162400 - Run Roll Forward Inventory Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10162400 - Run Roll Forward Inventory Report already EXISTS.'
END