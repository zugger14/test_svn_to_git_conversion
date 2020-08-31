UPDATE setup_menu 
SET 
function_id = 10234300 ,
window_name = 'windowAutomationofForecastedTransaction',
menu_type = 0
WHERE parent_menu_id = 13190000 AND product_category = 10000000 AND display_name = 'Automation of Forecasted Transaction'

UPDATE setup_menu 
SET 
window_name = 'windowDesignationofaHedgeFromMenu',
menu_type = 0
WHERE parent_menu_id = 13190000 AND product_category = 10000000 AND display_name = 'Designation of a Hedge'