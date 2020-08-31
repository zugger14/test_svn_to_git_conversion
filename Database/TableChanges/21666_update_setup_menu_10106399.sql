--Update setup_menu
UPDATE setup_menu
SET display_name = 'Data Import/Export'
WHERE [function_id] = 10106399
AND [product_category]= 10000000
PRINT 'Updated Setup Menu.'            