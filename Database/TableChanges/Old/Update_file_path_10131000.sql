UPDATE application_functions
SET    file_path = '_deal_capture/maintain_deals/maintain.deals.php',
       function_name = 'Create and View Deals'
WHERE  function_id = 10131000

UPDATE setup_menu
SET    display_name     = 'Create and View Deals'
WHERE  function_id      = 10131000