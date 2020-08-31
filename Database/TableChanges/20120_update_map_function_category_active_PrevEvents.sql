UPDATE mfc 
SET mfc.is_active = 1
FROM map_function_category mfc
INNER JOIN static_data_value sdv ON mfc.function_id = sdv.value_id
WHERE sdv.code IN ('PrevEvents')