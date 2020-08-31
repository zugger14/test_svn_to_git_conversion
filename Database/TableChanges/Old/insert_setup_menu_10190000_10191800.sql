IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10190000 AND sm.product_category = 10000000 )
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
VALUES  ( 10190000 , 
          NULL ,
          'Credit Risk And Analysis' ,
          NULL ,
          1 , 
          10000000 , 
          10000000 , 
          133 , 
          1  
)
ELSE
	PRINT 'In menu setup function Id 10190000 for product category 10000000 already exist. '
	
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10191800 AND sm.product_category = 10000000 )	
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
VALUES  ( 10191800 , 
          NULL , 
          'Calculate Credit Exposure' ,
          NULL ,
          1 , 
          10190000 , 
          10000000 , 
          112 , 
          0 
)

ELSE
	PRINT 'In menu setup function Id 10191800 for product category 10000000 already exist. '