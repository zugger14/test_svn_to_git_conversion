UPDATE fep SET sql_string = 'SELECT 1 [id], ''1'' [value] UNION ALL SELECT 2 [id], ''2'' [value] UNION ALL SELECT 3 [id], ''3'' [value] UNION ALL SELECT 4 [id], ''4'' [value] UNION ALL SELECT 5 [id], ''5'' [value] UNION ALL SELECT 6 [id], ''6'' [value] UNION ALL SELECT 7 [id], ''7'' [value] UNION ALL SELECT 8 [id], ''8'' [value] UNION ALL SELECT 9 [id], ''9'' [value] UNION ALL SELECT 10 [id], ''10'' [value] UNION ALL SELECT 11 [id], ''11'' [value] UNION ALL SELECT 12 [id], ''12'' [value]'
FROM formula_editor_parameter fep
       INNER JOIN static_data_value sdv
              ON  sdv.value_id = fep.formula_id
WHERE sdv.code = 'ContractValue' AND fep.field_label = 'Month'