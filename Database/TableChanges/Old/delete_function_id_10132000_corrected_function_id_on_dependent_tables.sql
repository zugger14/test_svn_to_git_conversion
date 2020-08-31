UPDATE application_functions
SET    func_ref_id     = 10131000
WHERE  func_ref_id     = 10132000
GO

UPDATE application_functions
SET file_path = '_deal_capture/maintain_deals/maintain.deals.new.php'
WHERE  function_id     = 10131000
GO

UPDATE application_functional_users
SET function_id = 10131000
WHERE function_id = 10132000
GO

UPDATE setup_menu
SET    hide_show       = 1
WHERE  function_id     = 10131000
GO

DELETE setup_menu
WHERE  function_id = 10132000
GO

UPDATE favourites_menu
SET function_id     = 10131000
WHERE function_id = 10132000
GO

UPDATE user_application_log
SET function_id     = 10131000
	, function_name = 'Create and View Deals'
WHERE function_id = 10132000
GO

DELETE application_functions
WHERE  function_id = 10132000
GO