UPDATE application_functions 
SET file_path = '_setup/maintain_static_data/maintain.static.data.php'
WHERE function_id = 10101000


UPDATE setup_menu 
SET  display_name = 'Setup Static Data' 
WHERE function_id = 10101000 AND display_name = 'Maintain Static Data'