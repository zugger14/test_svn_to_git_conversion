IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10192200 AND sm.product_category = 10000000 )	
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
VALUES  ( 10192200 , 
          'windowCalcCreditValueAdjustment' , 
          'Calculate Credit Value Adjustment' ,
          NULL ,
          1 , 
          10190000 , 
          10000000 , 
          114 , 
          0 
)

ELSE
	PRINT 'In menu setup function Id 10192200 for product category 10000000 already exist. '
