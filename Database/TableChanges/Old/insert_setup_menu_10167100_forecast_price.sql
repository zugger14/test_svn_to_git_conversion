IF NOT EXISTS (
	SELECT 1 from setup_menu WHERE window_name = 'windowForecastPrice' AND function_id = 10167100
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
		'10167100',
		'windowForecastPrice',
		'Forecast Price',
		NULL,
		1,
		10160000,
		10000000,
		111,
		1
	)
END