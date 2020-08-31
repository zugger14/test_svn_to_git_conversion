IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10131600 and product_category=10000000)
	BEGIN
	insert into setup_menu (function_id, window_name, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
    values(10131600, 'windowTransferBookPosition','Transfer Book Position' ,1, 10130000, 10000000, 3, 1)
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131600 already EXISTS.'
END

