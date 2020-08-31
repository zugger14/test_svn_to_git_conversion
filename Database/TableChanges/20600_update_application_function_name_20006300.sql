IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20006300)
BEGIN
	UPDATE application_functions
	SET function_name = 'Setup Default Application Theme',
		function_desc = 'Setup Default Application Theme'
	WHERE function_id = 20006300

END

IF EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20006300 AND sm.product_category = 10000000)
BEGIN
	UPDATE setup_menu
	SET display_name = 'Setup Default Application Theme'
	WHERE function_id = 20006300
		AND product_category = 10000000
END
