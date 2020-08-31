UPDATE mfc
	SET mfc.is_active = 1
FROM static_data_value sdv
INNER JOIN map_function_category mfc
	ON mfc.function_id = sdv.value_id
WHERE sdv.TYPE_ID = 800
AND code  = 'DealTotalVolm' 
