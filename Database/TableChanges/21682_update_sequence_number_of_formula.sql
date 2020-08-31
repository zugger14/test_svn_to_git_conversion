SELECT
  formula_param_id,	
  function_name,	 
  ROW_NUMBER() OVER(PARTITION BY function_name ORDER BY function_name ASC) 
    AS row_num,
  [sequence]
INTO #temp_formula_editor_parameter
FROM formula_editor_parameter
WHERE function_name IS NOT NULL
ORDER BY function_name,[sequence]

UPDATE fep
	SET fep.[sequence] = tfep.row_num
FROM formula_editor_parameter fep
INNER JOIN #temp_formula_editor_parameter tfep
	ON tfep.formula_param_id = fep.formula_param_id

