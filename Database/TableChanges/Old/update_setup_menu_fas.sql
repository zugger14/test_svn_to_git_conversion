UPDATE setup_menu
SET display_name = 'Hedging Strategies'
WHERE function_id = 12191099
AND parent_menu_id = 13190000
AND product_category = 13000000

DECLARE @ids INT
DECLARE @count INT
SELECT @count = COUNT(setup_menu_id) FROM setup_menu sm 
WHERE function_id = 10233800
	AND parent_menu_id = 12193099
	AND product_category = 13000000
--SELECT @count 

IF @count > 1
BEGIN
	SELECT TOP 1 @ids = setup_menu_id FROM setup_menu sm 
	WHERE function_id = 10233800
	AND parent_menu_id = 12193099
	AND product_category = 13000000

	--SELECT @ids
	DELETE FROM setup_menu WHERE setup_menu_id = @ids
	
END


--SELECT * 
UPDATE sm 
SET sm.display_name = 'Run MTM Process'
FROM setup_menu sm 
WHERE sm.function_id = 10181000
	AND sm.product_category = 13000000
	AND sm.parent_menu_id = 13210000
	
UPDATE sm 
SET sm.display_name = 'Copy Prior MTM Value'
FROM setup_menu sm 
WHERE sm.function_id = 10233300
	AND sm.product_category = 13000000
	AND sm.parent_menu_id = 13210000	


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE display_name = 'Run Hedging Relationship Audit Report' )
BEGIN
	INSERT INTO setup_menu
	(
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
	SELECT 13160000, 'windowHedgingRelationshipReport', 'Run Hedging Relationship Audit Report', '', 1, 13121297, 13000000, 2, 0
END 


IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE display_name = 'Run Deal Audit Report' )
BEGIN
	INSERT INTO setup_menu
	(
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
	SELECT 10171100, 'windowTransactionAuditLog', 'Run Deal Audit Report', '', 1, 13121297, 13000000, 3, 0
END 


UPDATE sm 
SET sm.display_name = 'Run Derivative Position Report'
FROM setup_menu sm 
WHERE sm.function_id = 10141000
	AND sm.product_category = 13000000
	AND sm.parent_menu_id = 13121298	
	
UPDATE sm 
SET sm.window_name = 'windowDerivativePositionReport'
FROM setup_menu sm WHERE sm.parent_menu_id = 13121298
AND sm.function_id = 10141000
AND sm.product_category = 13000000	


UPDATE sm 
SET sm.hide_show = 0
FROM setup_menu sm 
WHERE sm.function_id = 10102300
	AND sm.product_category = 13000000

UPDATE sm 
SET sm.hide_show = 0
FROM setup_menu sm 
WHERE sm.function_id = 10103800
	AND sm.product_category = 13000000
