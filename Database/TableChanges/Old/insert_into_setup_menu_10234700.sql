IF EXISTS(SELECT 1 FROM setup_menu WHERE function_id IN (10234700))
BEGIN
	DELETE FROM setup_menu WHERE function_id IN (10234700)
END

UPDATE application_functions SET func_ref_id = 10130000 WHERE function_id =10234700
IF NOT EXISTS(SELECT * FROM setup_menu WHERE function_id = 10234700)
BEGIN
 	INSERT INTO setup_menu(function_id,display_name,parent_menu_id,window_name,product_category,menu_order,hide_show,menu_type)
	VALUES (10234700, 'Maintain Transactions Tagging',  10130000, 'windowMaintainTransactionsTagging',14000000,69,1,0)
 	PRINT ' Inserted 10234700 -Maintain Transactions Tagging.'
END
ELSE
BEGIN
	PRINT 'setup_menu FunctionID 10234700 - Maintain Transactions Tagging already EXISTS.'
END
