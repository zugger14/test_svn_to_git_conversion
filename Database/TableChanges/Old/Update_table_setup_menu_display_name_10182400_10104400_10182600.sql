IF EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10182400 AND product_category = 10000000)
BEGIN
	UPDATE setup_menu
	SET    display_name = 'Financial Model Report'
	WHERE  function_id = 10182400
	       AND product_category = 10000000
END

IF EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10104400 AND product_category = 10000000)
BEGIN
	UPDATE setup_menu
	SET    display_name = 'Setup Price'
	WHERE  function_id = 10104400
	       AND product_category = 10000000
END

IF EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10182600 AND product_category = 10000000)
BEGIN
	UPDATE setup_menu
	SET    display_name = 'Calculate Financial Model'
	WHERE  function_id = 10182600
	       AND product_category = 10000000
END