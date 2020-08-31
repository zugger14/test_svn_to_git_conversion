
UPDATE setup_menu
SET    parent_menu_id = 13190000
WHERE  function_id = 10231997
       AND product_category = 13000000


UPDATE setup_menu
SET    parent_menu_id = 10231997
WHERE  function_id IN (10231900, 10232000)
       AND product_category = 13000000
     