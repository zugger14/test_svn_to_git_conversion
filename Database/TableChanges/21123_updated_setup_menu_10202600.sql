-- Change "Excel Add-in Report Manager" to "Excel Add-in Manager"
UPDATE setup_menu
SET display_name = 'Excel Add-In Manager'
WHERE function_id = 10202600
AND product_category = 10000000
