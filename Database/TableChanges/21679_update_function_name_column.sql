UPDATE mpc
SET mpc.function_name = sdv.code,
	mpc.function_desc = sdv.description
FROM map_function_category mpc
INNER JOIN static_data_value sdv
	ON sdv.value_id = mpc.function_id

UPDATE fep
SET fep.function_name = sdv.code 
FROM formula_editor_parameter fep
INNER JOIN static_data_value sdv
	ON sdv.value_id = fep.formula_id

UPDATE mfp
SET mfp.function_name = sdv.code 
FROM map_function_product mfp
INNER JOIN static_data_value sdv
	ON sdv.value_id = mfp.function_id





