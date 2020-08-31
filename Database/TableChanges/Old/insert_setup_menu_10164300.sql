IF NOT EXISTS (
	SELECT 1 from setup_menu WHERE window_name = 'windowEDI' AND function_id = 10164300
)
BEGIN
	INSERT INTO setup_menu (
		-- setup_menu_id -- this column value is auto-generated
		function_id,
		window_name,
		display_name,
		default_parameter,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order,
		menu_type
	)
	VALUES(
		'10164300',
		'windowEDI',
		'EDI View',
		NULL,
		1,
		10160000,
		10000000,
		114,
		1
	)
END
IF EXISTS (SELECT 1 from setup_menu WHERE window_name = 'windowEDI' AND function_id = 10164300 )
begin
	update setup_menu set display_name = 'Nomination EDI', menu_type = 0 where function_id = 10164300
end