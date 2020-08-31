--Update code to hide 'Run Hedging Relationship Types Report' in all product
UPDATE setup_menu
SET 
hide_show = 0 
WHERE function_id =  10232000 

