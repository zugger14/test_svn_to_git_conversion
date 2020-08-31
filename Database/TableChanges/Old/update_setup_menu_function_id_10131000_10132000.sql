
/*
* Made hidden to 'Create and View Deals'
* */
UPDATE setup_menu
SET    hide_show = 0
WHERE  function_id = 10131000
       AND product_category = 10000000

/*
* Rename 'Create and View Deals New' menu to 'Create and View Deals'
* */
UPDATE setup_menu
SET    display_name             = 'Create and View Deals'
WHERE  function_id              = 10132000
       AND product_category     = 10000000
       
      