IF EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10106100 AND product_category = 10000000 AND display_name = 'Setup Time Series')
	BEGIN
	UPDATE
	setup_menu
	SET
	hide_show = 0 
	WHERE
	product_category = 10000000
	and display_name = 'Setup Time Series'
	END
ELSE PRINT 'Setup Time Series Menu doesnot exists.'