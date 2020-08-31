
DECLARE @mapping_table_id     INT,
        @mapping_name         VARCHAR(200) = 'Contract Curves' 

SELECT @mapping_table_id = mapping_table_id
FROM   generic_mapping_header
WHERE  mapping_name = @mapping_name

DELETE gmv
--SELECT gmv.generic_mapping_values_id
	  --, sc.source_counterparty_id
	  --, gmv.clm1_value
FROM generic_mapping_values gmv
     LEFT JOIN source_counterparty sc ON gmv.clm1_value = sc.source_counterparty_id
WHERE gmv.mapping_table_id = @mapping_table_id AND  sc.source_counterparty_id IS NULL

DELETE gmv
--SELECT gmv.generic_mapping_values_id
	 -- , cg.contract_id
	 -- ,  gmv.clm1_value
FROM generic_mapping_values gmv
     LEFT JOIN contract_group cg ON gmv.clm2_value = cg.contract_id
WHERE gmv.mapping_table_id = @mapping_table_id AND cg.contract_id IS NULL

DELETE gmv
--SELECT gmv.generic_mapping_values_id
	 -- , spcd.source_curve_def_id 
	 -- , gmv.clm4_value
FROM generic_mapping_values gmv
     LEFT JOIN source_price_curve_Def spcd ON gmv.clm4_value = spcd.source_curve_def_id
WHERE gmv.mapping_table_id = @mapping_table_id AND  spcd.source_curve_def_id IS NULL