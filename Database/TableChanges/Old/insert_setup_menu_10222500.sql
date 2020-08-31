IF NOT EXISTS(SELECT * FROM setup_menu WHERE function_id = 10222500)
BEGIN
 	INSERT INTO setup_menu(function_id,display_name,parent_menu_id,window_name,product_category,menu_order,hide_show)
	VALUES (10222500, 'Print Invoices',  10220000, 'windowPrintInvoices',10000000,15,1)
 	PRINT ' Inserted 10222500 - Print Invoices.'
END
ELSE
BEGIN
	PRINT 'setup_menu FunctionID 10222500 - Print Invoices already EXISTS.'
END