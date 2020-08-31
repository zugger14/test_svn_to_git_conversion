IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10238000 AND product_category = 13000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10238000, 'windowMaintainTransactionsTagging', 'Maintain Transactions Tagging', '', 1, 10131099, 13000000, '', 0)
    PRINT 'Maintain Transactions Tagging - 10238000 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10238000 already exists.'
END 

/*Insert missing function id for new FASTracker menus start*/
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 13180000)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (13180000, 'ETRM Interfaces', 'ETRM Interfaces', 13000000, NULL)
 	PRINT ' Inserted 13180000 - ETRM Interfaces.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 13180000 - ETRM Interfaces already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 13190000)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (13190000, 'Hedge Management', 'Hedge Management', 13000000, NULL)
 	PRINT ' Inserted 13190000 - Hedge Management.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 13190000 - Hedge Management already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 13200000)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (13200000, 'Hedge Effectivenesss Testing', 'Hedge Effectivenesss Testing', 13000000, NULL)
 	PRINT ' Inserted 13200000 - Hedge Effectivenesss Testing.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 13200000 - Hedge Effectivenesss Testing already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 13210000)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (13210000, 'Hedge Ineffectivenesss Measurement', 'Hedge Ineffectivenesss Measurement', 13000000, NULL)
 	PRINT ' Inserted 13210000 - Hedge Ineffectivenesss Measurement.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 13210000 - Hedge Ineffectivenesss Measurement already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 13220000)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (13220000, 'Disclosures', 'Disclosures', 13000000, NULL)
 	PRINT ' Inserted 13220000 - Disclosures.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 13220000 - Disclosures already EXISTS.'
END
/*Insert missing function id in setu menu for new FASTracker menus start*/


/*Insert missing function id for new FASTracker menus start*/
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 13180000 AND product_category = 13000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (13180000, '', 'ETRM Interfaces', '', 1, 13000000, 13000000, '', 0)
    PRINT 'ETRM Interfaces - 13180000 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 13180000 already exists.'
END

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 13190000 AND product_category = 13000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (13190000, '', 'Hedge Management', '', 1, 13000000, 13000000, '', 0)
    PRINT 'Hedge Management - 13190000 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 13190000 already exists.'
END

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 13200000 AND product_category = 13000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (13200000, '', 'Hedge Effectivenesss Testing', '', 1, 13000000, 13000000, '', 0)
    PRINT 'Hedge Effectivenesss Testing - 13200000 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 13200000 already exists.'
END

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 13210000 AND product_category = 13000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (13210000, '', 'Hedge Ineffectivenesss Measurement', '', 1, 13000000, 13000000, '', 0)
    PRINT 'Hedge Ineffectivenesss Measurement - 13210000 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 13210000 already exists.'
END

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 13220000 AND product_category = 13000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (13220000, '', 'Disclosures', '', 1, 13000000, 13000000, '', 0)
    PRINT 'Disclosures - 13220000 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 13220000 already exists.'
END
/*Insert missing function id in setu menu for new FASTracker menus end*/

/* etrm inteface menus start*/
UPDATE sm
SET sm.parent_menu_id = 13180000
FROM setup_menu sm 
WHERE sm.function_id = 10131300 AND sm.product_category = 13000000

UPDATE sm
SET sm.parent_menu_id = 13180000
FROM setup_menu sm 
WHERE sm.function_id = 10232800 AND sm.product_category = 13000000

UPDATE sm
SET sm.parent_menu_id = 13180000
FROM setup_menu sm 
WHERE sm.function_id = 10232900 AND sm.product_category = 13000000

UPDATE sm
SET sm.parent_menu_id = 13180000
FROM setup_menu sm 
WHERE sm.function_id = 10233000 AND sm.product_category = 13000000

/* etrm inteface menus end*/


/*hedge management menu start*/
--sub menu category start
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 12191099 AND product_category = 13000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (12191099, '', 'Effectiveness Reporting', '', 1, 13190000, 13000000, '', 1)
    PRINT 'Effectiveness Reporting - 12191099 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 12191099 already exists.'
END

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 12192099 AND product_category = 13000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (12192099, '', 'Hedge Designation', '', 1, 13190000, 13000000, '', 1)
    PRINT 'Hedge Designation - 12192099 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 12192099 already exists.'
END

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 12193099 AND product_category = 13000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (12193099, '', 'Hedge De-Designation', '', 1, 13190000, 13000000, '', 1)
    PRINT 'De-Designation - 12193099 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 12193099 already exists.'
END
--sub menu category end 
--hedging strategies start
UPDATE setup_menu
SET parent_menu_id = 12191099
WHERE function_id = 10231900
	AND product_category = 13000000	
	
	UPDATE setup_menu
SET parent_menu_id = 12191099
WHERE function_id = 10232000
	AND product_category = 13000000	
--hedging strategies end 	

--hedge designation menu start
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10233900 AND product_category = 13000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10233900, 'windowRunHedgeRelationshipReport', 'Run Hedging Relationship Report', '', 1, 12192099, 13000000, '', 0)
    PRINT 'Run Hedging Relationship Report - 10233900 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10230095 already exists.'
END	

UPDATE setup_menu
SET parent_menu_id = 12192099
WHERE function_id = 10234300
	AND product_category = 13000000	

UPDATE setup_menu
SET parent_menu_id = 12192099
WHERE function_id = 10234400
	AND product_category = 13000000		

UPDATE setup_menu
SET parent_menu_id = 12192099
WHERE function_id = 10234500
	AND product_category = 13000000			

UPDATE setup_menu
SET parent_menu_id = 12192099
WHERE function_id = 10234200
	AND product_category = 13000000			

UPDATE setup_menu
SET parent_menu_id = 12192099
WHERE function_id = 10234100
	AND product_category = 13000000		

UPDATE setup_menu
SET parent_menu_id = 12192099
WHERE function_id = 10233700
	AND product_category = 13000000
--hedge designation menu end 

--hedge de-designation menu start
UPDATE setup_menu 
SET function_id = 10234000
WHERE display_name = 'Reclassify Hedge De-Designation'

UPDATE setup_menu
SET parent_menu_id = 12193099
WHERE function_id = 10233800
	AND product_category = 13000000	

UPDATE setup_menu
SET parent_menu_id = 12193099
WHERE function_id = 10234000
	AND product_category = 13000000	

UPDATE setup_menu
SET parent_menu_id = 12193099
WHERE function_id = 10233896
	AND product_category = 13000000		

--hedge de-designation menu end

/*hedge management menu end*/

/*hedge eff testing menu start*/
UPDATE setup_menu
SET parent_menu_id = 13200000
WHERE function_id = 10151000
	AND product_category = 13000000

UPDATE setup_menu
SET parent_menu_id = 13200000
WHERE function_id = 10232300
	AND product_category = 13000000
	
UPDATE setup_menu
SET parent_menu_id = 13200000
WHERE function_id = 10232400
	AND product_category = 13000000
	
UPDATE setup_menu
SET parent_menu_id = 13200000
WHERE function_id = 10232500
	AND product_category = 13000000		

UPDATE setup_menu
SET parent_menu_id = 13200000
WHERE function_id = 10237300
	AND product_category = 13000000		
	
UPDATE setup_menu
SET parent_menu_id = 13200000
WHERE function_id = 10232600
	AND product_category = 13000000	
/*hedge eff testing menu end*/

/*hedge ineff measurement menu start*/
UPDATE setup_menu
SET parent_menu_id = 13210000
WHERE function_id = 10233400
	AND product_category = 13000000

UPDATE setup_menu
SET parent_menu_id = 13210000
WHERE function_id = 10181000
	AND product_category = 13000000	

UPDATE setup_menu
SET parent_menu_id = 13210000
WHERE function_id = 10181100
	AND product_category = 13000000	

UPDATE setup_menu
SET parent_menu_id = 13210000
WHERE function_id = 10233200
	AND product_category = 13000000	

UPDATE setup_menu
SET parent_menu_id = 13210000
WHERE function_id = 10233300
	AND product_category = 13000000		

UPDATE setup_menu
SET parent_menu_id = 13210000
WHERE function_id = 10234610
	AND product_category = 13000000			
	
UPDATE setup_menu
SET parent_menu_id = 13210000
WHERE function_id = 10233500
	AND product_category = 13000000	

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 13151000 AND product_category = 13000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (13151000, 'windowCalcDynamicLimit', 'Calc Dynamic Limit and Designaton/ De-designation', '', 1, 13210000, 13000000, '', 0)
    PRINT 'Calc Dynamic Limit and Designaton/ De-designation - 13151000 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10230095 already exists.'
END	
/*hedge ineff measurement menu end*/

/*hedge disclosures menu start*/
UPDATE setup_menu
SET parent_menu_id = 13220000
WHERE function_id = 10235700
	AND product_category = 13000000	

UPDATE setup_menu
SET parent_menu_id = 13220000
WHERE function_id = 10235600
	AND product_category = 13000000
	
UPDATE setup_menu
SET parent_menu_id = 13220000
WHERE function_id = 10235100
	AND product_category = 13000000		
/*hedge disclosures menu end*/

GO