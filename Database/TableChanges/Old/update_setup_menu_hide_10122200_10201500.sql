--Update code to hide 'View Compliance calendar' and 'Run Static Data Audit Report' in product TRMTracker
UPDATE setup_menu
SET 
hide_show = 0 
WHERE function_id IN (10122200,10201500) 
AND product_category = 10000000

