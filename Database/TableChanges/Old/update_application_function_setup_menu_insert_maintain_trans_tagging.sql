UPDATE application_functions
SET    function_name = 'Maintain Deal Transfer',
       function_desc = 'Maintain Deal Transfer',
       func_ref_id = 10230000,
       function_call = 'windowMaintainDealTransfer'
WHERE  [function_id] = 10234700

PRINT 'Updated Application Function '
UPDATE application_functions
SET    function_name = 'Update Maintain Deal Transfer',
       function_desc = 'Update Maintain Deal Transfer',
       func_ref_id = 10234700,
       function_call = 'windowUpdateMaintainDealTransfer'
WHERE  [function_id] = 10234710

PRINT 'Updated Application Function '



/*trm start*/
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10238000)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10238000, 'Maintain Transaction Tagging', 'Maintain Transaction Tagging', 10230000, 'windowMaintainTransactionsTagging')
 	PRINT ' Inserted 10238000 - Maintain Transaction Tagging.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10238000 - Maintain Transaction Tagging already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10238010)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10238010, 'Update Maintain Transactions Tagging', 'Update Maintain Transactions Tagging', 10238000, 'windowMaintainTransactionsTagging')
 	PRINT ' Inserted 10238010 - Update Maintain Transactions Tagging.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10238010 - Update Maintain Transactions Tagging already EXISTS.'
END


/*trm end */


/* fas start*/
IF NOT EXISTS(
       SELECT 1
       FROM   application_functions
       WHERE  function_id = 13141000
   )
BEGIN
    INSERT INTO application_functions
      (
        function_id,
        function_name,
        function_desc,
        func_ref_id,
        function_call
      )
    VALUES
      (
        13141000,
        'Maintain Transactions Tagging',
        'Maintain Transactions Tagging',
        13140000,
        'windowMaintainTransactionsTagging'
      )
    PRINT ' Inserted 13141000 - Maintain Transactions Tagging.'
END
ELSE
BEGIN
    PRINT 
    'Application FunctionID 13141000 - Maintain Transactions Tagging already EXISTS.'
END


IF NOT EXISTS(
       SELECT 1
       FROM   application_functions
       WHERE  function_id = 13141010
   )
BEGIN
    INSERT INTO application_functions
      (
        function_id,
        function_name,
        function_desc,
        func_ref_id,
        function_call
      )
    VALUES
      (
        13141010,
        'Update Maintain Transactions Tagging',
        'Update Maintain Transactions Tagging',
        13141000,
        'windowTransactionAuditReport'
      )
    PRINT ' Inserted 13141010 - Update Maintain Transactions Tagging.'
END
ELSE
BEGIN
    PRINT 'Application FunctionID 13141010 - Update Maintain Transactions Tagging already EXISTS.'
END
/* fas end */
/*
SELECT * FROM application_functions af WHERE function_desc LIKE '%Maintain Transactions Tagging%'
SELECT * FROM application_functions af WHERE function_desc LIKE '%Maintain Deal Transfer%'
*/

/* insert and update setup menu */
UPDATE setup_menu
SET    window_name = 'windowMaintainDealTransfer',
       display_name = 'Maintain Deal Transfer',
       hide_show = 1,
       parent_menu_id = 10130000       
WHERE  function_id = 10234700
       --AND product_category = 10000000
       
       
-- Insert Accounting derivative Transaction Processing
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10230095 AND product_category = 13000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10230095, NULL, 'Accounting derivative Transaction Processing', '', 1, 13000000, 13000000, '', 1)
    PRINT 'Accounting derivative Transaction Processing - 10230095 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10230095 already exists.'
END

-- Insert Maintain Transactions Tagging--fas
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 13141000 AND product_category = 13000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (13141000, 'windowMaintainTransactionsTagging', 'Maintain Transactions Tagging', '', 1, 10230095, 13000000, '', 0)
    PRINT 'Maintain Transactions Tagging - 13141000 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 13141000 already exists.'
END

-- Insert Maintain Transactions Tagging--trm
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10238000 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,
                           menu_order, menu_type)
    VALUES (10238000, 'windowMaintainTransactionsTagging', 'Maintain Transactions Tagging', '', 1, 10230095, 10000000, '', 0)
    PRINT 'Maintain Transactions Tagging - 10238000 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10238000 already exists.'
END