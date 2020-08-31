IF NOT EXISTS (SELECT 1 FROM map_function_category WHERE function_name = 'StorageContractPrice') 

BEGIN 

INSERT INTO map_function_category(category_id, function_name, is_active) 

VALUES (27403, 'StorageContractPrice', 1) 

END 