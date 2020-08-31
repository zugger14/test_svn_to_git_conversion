IF NOT EXISTS (
	SELECT 1 from setup_menu WHERE window_name = 'windowDealConfirmationRule' AND function_id = 10101161
)
BEGIN
	INSERT INTO setup_menu (
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
		'10101161',
		'windowDealConfirmationRule',
		'Setup Confirmation Rule',
		NULL,
		1,
		10100000,
		10000000,
		16,
		0
	)
END