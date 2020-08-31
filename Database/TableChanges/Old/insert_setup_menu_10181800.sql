IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10181800  AND product_category = 10000000)
BEGIN
	INSERT INTO dbo.setup_menu
			( function_id ,
			  window_name ,
			  display_name ,
			  default_parameter ,
			  hide_show ,
			  parent_menu_id ,
			  product_category ,
			  menu_order ,
			  menu_type 
			)
	VALUES  ( 10181800,
			  NULL,
			  'Run Implied Volatility Calculation',
			  NULL,
			  1,
			  10181499,
			  10000000,
			  134,
			  1
			)
END
ELSE 
BEGIN
	PRINT 'Run Implied Volatility Calculation - Menu already Exists.'
END