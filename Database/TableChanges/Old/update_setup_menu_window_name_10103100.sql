--Update code to change call function of Term mapping
UPDATE setup_menu
SET    window_name = 'windowSetupTrayportTermMapping'
WHERE  function_id = 10103100
       AND product_category = 10000000

PRINT 'Updated setup_menu, window_name -windowSetupTrayportTermMapping.'

