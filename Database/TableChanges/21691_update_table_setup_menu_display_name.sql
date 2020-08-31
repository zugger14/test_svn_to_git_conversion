-- Delete setup_menu
DELETE setup_menu
WHERE [function_id] = 10131300
	AND [display_name] = 'Price Curves Import'

--Update setup_menu
UPDATE setup_menu
SET display_name = 'Data Import Old',
    hide_show = 0
WHERE [function_id] = 10131300
PRINT 'Updated Setup Menu.' 