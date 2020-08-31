--Run Volatility Calculations
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10181499  AND product_category = 10000000)
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
VALUES  ( 10181499 , -- function_id - int
          NULL , -- window_name - varchar(1000)
          'Run Volatility Calculations' , -- display_name - varchar(200)
          NULL , -- default_parameter - varchar(5000)
          1 , -- hide_show - bit
          10180000 , -- parent_menu_id - int
          10000000 , -- product_category - int
          133 , -- menu_order - int
          1  -- menu_type - bit
        )
END
ELSE 
BEGIN
	PRINT 'Run Volatility Calculations - Menu already Exists.'
END

--Calculate Volatility, Correlation and Expected Return
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10181400  AND product_category = 10000000)
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
VALUES  ( 10181400 , -- function_id - int
          NULL , -- window_name - varchar(1000)
          'Calculate Volatility, Correlation and Expected Return' , -- display_name - varchar(200)
          NULL , -- default_parameter - varchar(5000)
          1 , -- hide_show - bit
          10181499 , -- parent_menu_id - int
          10000000 , -- product_category - int
          133 , -- menu_order - int
          1  -- menu_type - bit
        )
END
ELSE 
BEGIN
	PRINT 'Calculate Volatility, Correlation and Expected Return - Menu already Exists.'
END