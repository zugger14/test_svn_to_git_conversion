IF NOT EXISTS (
	SELECT 1 from setup_menu WHERE window_name = 'windowReportManagerDHX' AND function_id = 10202500
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
		10202500,
		'windowReportManagerDHX',
		'Report Manager DHX',
		NULL,
		1,
		10200000,
		10000000,
		43,
		1
	)
END
--delete from setup_menu WHERE window_name = 'windowReportManagerDHX' AND function_id = 10202500