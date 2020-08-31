IF OBJECT_ID('tempdb..#temp_generic_mapping') IS NOT NULL
    DROP TABLE #temp_generic_mapping

DECLARE @mapping_table_id INT
SELECT @mapping_table_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'Valid Templates';

DELETE gmv
FROM   generic_mapping_values gmv
INNER JOIN generic_mapping_header gmh ON  gmv.mapping_table_id = gmh.mapping_table_id
WHERE  gmh.mapping_name = 'Valid Templates'

CREATE TABLE #temp_generic_mapping (
	[template] VARCHAR(100)
)

INSERT INTO #temp_generic_mapping([template])
VALUES('Physical NG')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value)
SELECT @mapping_table_id [mapping_table_id],
       sdht.template_id
FROM   #temp_generic_mapping tgm
INNER JOIN source_deal_header_template sdht ON  sdht.template_name = tgm.[template]
LEFT JOIN generic_mapping_values gmv
    ON  gmv.mapping_table_id = @mapping_table_id
    AND clm1_value = sdht.template_id
WHERE  gmv.generic_mapping_values_id IS NULL