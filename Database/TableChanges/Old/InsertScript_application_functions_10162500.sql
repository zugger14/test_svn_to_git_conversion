-- Script to insert Application Function Id :
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10162500)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10162500, 'Run Inventory Calc', 'Run Inventory Calc', 10160000, 'windowRunInventoryCalc', '_settlement_billing/run_inventory_calc/run.inventory.calc.php')

 	PRINT 'Inserted 10162500 - Run Inventory Calc.'
END
ELSE
BEGIN
 	UPDATE application_functions SET file_path = '_settlement_billing/run_inventory_calc/run.inventory.calc.php' where function_id = 10162500;

	PRINT 'Updated 10162500 - Run Inventory Calc.'
END