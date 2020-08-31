IF OBJECT_ID('tempdb..#temp_generic_mapping') IS NOT NULL
    DROP TABLE #temp_generic_mapping

DECLARE @mapping_table_id INT
SELECT @mapping_table_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'Time Series Function ID Mapping';

DELETE FROM generic_mapping_values WHERE clm1_value = 10106200 AND mapping_table_id = @mapping_table_id

CREATE TABLE #temp_generic_mapping([Function ID] VARCHAR(100), [Series Type] INT , [Definition Add Function ID] VARCHAR(100), [Definition Delete Function ID] VARCHAR(100), [Value Add Function ID] VARCHAR(100));
INSERT INTO #temp_generic_mapping ([Function ID],  [Series Type],  [Definition Add Function ID],  [Definition Delete Function ID], [Value Add Function ID]) 
			VALUES ('10166200',39002,'10166210','10166211','10166212');

INSERT INTO generic_mapping_values
(
	mapping_table_id,
	clm1_value,
	clm2_value,
	clm3_value,
	clm4_value,
	clm5_value		
)
SELECT	@mapping_table_id, 
		tgm.[Function ID], 
		tgm.[Series Type], 
		tgm.[Definition Add Function ID], 
		tgm.[Definition Delete Function ID],
		tgm.[Value Add Function ID]
FROM #temp_generic_mapping tgm
LEFT JOIN generic_mapping_values gmv ON gmv.mapping_table_id = @mapping_table_id
AND clm1_value = tgm.[Function ID]
AND ISNULL(clm2_value,0) = ISNULL(tgm.[Series Type],0)
AND clm3_value = tgm.[Definition Add Function ID]
AND clm4_value = tgm.[Definition Delete Function ID]
AND clm5_value = tgm.[Value Add Function ID]
WHERE gmv.generic_mapping_values_id IS NULL

