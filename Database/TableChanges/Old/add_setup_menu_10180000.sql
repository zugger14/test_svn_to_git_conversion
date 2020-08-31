IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10180000  AND parent_menu_id = 10000000)
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
VALUES  ( 10180000 , -- function_id - int
          NULL , -- window_name - varchar(1000)
          'Valuation And Risk Analysis' , -- display_name - varchar(200)
          NULL , -- default_parameter - varchar(5000)
          1 , -- hide_show - bit
          10000000 , -- parent_menu_id - int
          10000000 , -- product_category - int
          133 , -- menu_order - int
          1  -- menu_type - bit
        )
END
ELSE 
BEGIN
	PRINT 'Menu already Exists.'
END