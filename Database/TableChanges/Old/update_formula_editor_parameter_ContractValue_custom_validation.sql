UPDATE fep 
SET custom_validation = 'non_negative'  
FROM formula_editor_parameter fep
       INNER JOIN static_data_value sdv
              ON  sdv.value_id = fep.formula_id
WHERE sdv.code = 'ContractValue' AND fep.field_label = 'Prior Month'