/*
* Renamed 'SAP Settlement Export' display name to 'Export GL Entries' 
* Made menu 'Export GL Entries' display under 'Settlement and Billing' Module
* */
UPDATE application_functions SET function_name= 'Export GL Entries' WHERE function_id = 10202201 
UPDATE setup_menu SET display_name = 'Export GL Entries', parent_menu_id = 10220000, hide_show = 1 WHERE function_id = 10202201 AND product_category =10000000
