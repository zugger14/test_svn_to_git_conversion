UPDATE application_functions SET function_name = 'Closed Settlement Accounting Period', function_desc = 'Closed Settlement Accounting Period' WHERE application_functions.function_id = 10233600

UPDATE setup_menu SET window_name = 'windowClosingAccountingPeriod', function_id = 10237500 WHERE display_name = 'Close Accounting Period' AND parent_menu_id = 10235499 AND product_category = 13000000
