IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10235600 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10235600, NULL, 'Accounting Disclosure Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10235200 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10235200, NULL, 'AOCI Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10235800 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10235800, NULL, 'Assessment Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10236400 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10236400, NULL, 'Available Hedge Capacity Exception Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10221200 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10221200, NULL, 'Contract Settlement Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10201900 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10201900, NULL, 'Data Import/Export Audit Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10235300 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10235300, NULL, 'De-designation Values Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10221900 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10221900, NULL, 'Deal Settlement Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10142400 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10142400, NULL, 'Derivative Position Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10236200 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10236200, NULL, 'Failed Assessment Values Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10235700 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10235700, NULL, 'Fair Value Disclosure Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10161400 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10161400, NULL, 'Gas Storage Position Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 13121200 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (13121200, NULL, 'Hedge Ineffectiveness Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 13160000 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (13160000, NULL, 'Hedging Relationship Audit Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10233900 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10233900, NULL, 'Hedging Relationship Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10232000 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10232000, NULL, 'Hedging Relationship Types Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10232800 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10232800, NULL, 'Import Audit Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10234200 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10234200, NULL, 'Life Cycle of Hedges', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10141900 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10141900, NULL, 'Load Forecast Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10234900 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10234900, NULL, 'Measurement Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10202100 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10202100, NULL, 'Message Board Log Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10222400 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10222400, NULL, 'Meter Data Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10236100 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10236100, NULL, 'Missing Assessment Values Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10235500 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10235500, NULL, 'Netted Journal Entry Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10236500 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10236500, NULL, 'Not Mapped Transaction Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10235100 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10235100, NULL, 'Period Change Values Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10162600 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10162600, NULL, 'Pipeline Imbalance Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10111300 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10111300, NULL, 'Privilege Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10201500 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10201500, NULL, 'Static Data Audit Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10111400 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10111400, NULL, 'System Access Log Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10236600 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10236600, NULL, 'Tagging Audit Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10171100 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10171100, NULL, 'Transaction Audit Log Report', NULL, 0, 10202200, 10000000, 1, 0)
END


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10202000 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10202000, NULL, 'User Activity Log Report', NULL, 0, 10202200, 10000000, 1, 0)
END
