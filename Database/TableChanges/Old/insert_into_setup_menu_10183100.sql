IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10183100 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order)
	VALUES (10183100, 'windowRunMonteCarloSimulation', 'Run Monte Carlo Simulation', NULL, 1, 10180000, 10000000, 133)
END