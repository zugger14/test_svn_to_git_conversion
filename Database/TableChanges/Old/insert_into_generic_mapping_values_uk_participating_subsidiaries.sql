IF OBJECT_ID('tempdb..#temp_generic_mapping') IS NOT NULL
    DROP TABLE #temp_generic_mapping
    
DECLARE @mapping_table_id_uk_participating_subsidiaries INT
SELECT @mapping_table_id_uk_participating_subsidiaries = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'UK Participating Subsidiaries';

DELETE gmv 
FROM generic_mapping_values gmv
INNER JOIN generic_mapping_header gmh ON gmv.mapping_table_id = gmh.mapping_table_id
WHERE gmh.mapping_name = 'UK Participating Subsidiaries'

IF OBJECT_ID('tempdb..#temp_generic_mapping') IS NOT NULL
	DROP TABLE #temp_generic_mapping

CREATE TABLE #temp_generic_mapping ([portfolio_hierarchy] VARCHAR(100))

INSERT INTO #temp_generic_mapping (portfolio_hierarchy) VALUES ('RWEST UK')

INSERT INTO generic_mapping_values
(
	mapping_table_id,
	clm1_value
)
SELECT	@mapping_table_id_uk_participating_subsidiaries [mapping_table_id], 
		ph.[entity_id]
FROM #temp_generic_mapping tgm
LEFT JOIN portfolio_hierarchy ph ON tgm.portfolio_hierarchy = ph.[entity_name] AND parent_entity_id IS NULL
LEFT JOIN generic_mapping_values gmv ON gmv.mapping_table_id = @mapping_table_id_uk_participating_subsidiaries
	AND clm1_value = ph.[entity_id]
WHERE gmv.generic_mapping_values_id IS NULL
