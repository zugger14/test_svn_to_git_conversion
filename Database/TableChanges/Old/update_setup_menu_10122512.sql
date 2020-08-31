IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10122512 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, product_category,menu_order)
	VALUES (10122512, 'Export Relationship', 10122500, 0, 1, 10000000,111)
	PRINT ' Setup Menu 10100000 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 10100000 already EXISTS.'
END

Update
application_functions 
set
func_ref_id = NULL 
where
function_id = 10221348

