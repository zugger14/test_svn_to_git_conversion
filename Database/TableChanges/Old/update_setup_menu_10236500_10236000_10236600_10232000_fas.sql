IF EXISTS (SELECT 1 FROM setup_menu WHERE parent_menu_id = 10202200 AND hide_show = 1)
Begin
UPDATE
setup_menu
SET
hide_show = 0
WHERE function_id IN (10236500,10236000,10236600, 10232000) AND product_category = 13000000 AND parent_menu_id = 10202200
End

IF EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10232300)
BEGIN
UPDATE 
application_functions
SET
file_path = '_accounting/derivative/transaction_processing/des_of_a_hedge/view.link.php?function_id=10232300'
WHERE function_id = 10232300
END


IF EXISTS (SELECT 1 FROM setup_menu WHERE product_category = 13000000 AND display_name LIKE 'Run Hedging Relationship Report')
BEGIN 
DELETE FROM setup_menu
WHERE 
product_category = 13000000 AND display_name LIKE 'Run Hedging Relationship Report'
END

IF EXISTS (SELECT 1 FROM setup_menu WHERE product_category = 13000000 AND display_name LIKE 'Run Hedging Relationship Types Report')
BEGIN 
DELETE FROM setup_menu
WHERE 
product_category = 13000000 AND display_name LIKE 'Run Hedging Relationship Types Report'
END

IF EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10234000)
Begin
UPDATE
application_functions
SET
file_path = '_accounting/derivative/transaction_processing/reclassify_dedes_values/reclassify.dedes.values.php'
WHERE
function_id = 10234000
END

IF EXISTS (SELECT * FROM setup_menu WHERE function_id IN (10236500,10236600,10236000) AND product_category = 13000000)
Begin
UPDATE
setup_menu
SET
parent_menu_id = 10202200
WHERE
function_id IN (10236500,10236600,10236000)
AND 
product_category = 13000000
END