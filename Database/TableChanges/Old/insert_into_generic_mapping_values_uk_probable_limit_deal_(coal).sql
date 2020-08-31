IF OBJECT_ID('tempdb..#temp_generic_mapping') IS NOT NULL
    DROP TABLE #temp_generic_mapping
    
DECLARE @mapping_table_id_uk_probable_limit_coal INT
SELECT @mapping_table_id_uk_probable_limit_coal = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'UK Probable Limit Deal (Coal)';

DELETE gmv 
FROM generic_mapping_values gmv
INNER JOIN generic_mapping_header gmh ON gmv.mapping_table_id = gmh.mapping_table_id
WHERE gmh.mapping_name = 'UK Probable Limit Deal (Coal)'

-- SELECT source_book_id, source_book_name FROM source_book where source_system_book_type_value_id=50
--SELECT source_book_id, source_book_name FROM source_book where source_system_book_type_value_id=51
--SELECT source_book_id, source_book_name FROM source_book where source_system_book_type_value_id=52
--SELECT source_book_id, source_book_name FROM source_book where source_system_book_type_value_id=53
--select value_id,code from static_data_value where type_id=400

IF OBJECT_ID('tempdb..#temp_generic_mapping') IS NOT NULL
	DROP TABLE #temp_generic_mapping

CREATE TABLE #temp_generic_mapping ([internal_portfolio] VARCHAR(100),[counterparty_group] VARCHAR(100), [instrument_type] VARCHAR(100), [proj_index_group] VARCHAR(100), [transaction_type] VARCHAR(100))

INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [proj_index_group], [transaction_type]) VALUES ('User Defined Limit-Coal', 'None_FT', 'None_FT','Coal','Out of Scope')

INSERT INTO generic_mapping_values
(
	mapping_table_id,
	clm1_value,
	clm2_value,
	clm3_value,
	clm4_value,
	clm5_value
)
SELECT	@mapping_table_id_uk_probable_limit_coal [mapping_table_id], 
		sb.[source_book_id],
		sb2.[source_book_id],
		sb1.[source_book_id],
		sb3.[source_book_id],
		sdv.value_id
FROM #temp_generic_mapping tgm
LEFT JOIN source_book sb ON tgm.internal_portfolio = sb.[source_book_name] AND sb.source_system_book_type_value_id = 50
LEFT JOIN source_book sb2 ON tgm.[counterparty_group] = sb2.[source_book_name] AND sb2.source_system_book_type_value_id = 51
LEFT JOIN source_book sb1 ON tgm.[instrument_type] = sb1.[source_book_name] AND sb1.source_system_book_type_value_id = 52
LEFT JOIN source_book sb3 ON tgm.[proj_index_group] = sb3.[source_book_name] AND sb3.source_system_book_type_value_id = 53
LEFT JOIN static_data_value sdv ON tgm.[transaction_type] = sdv.code AND sdv.[type_id] = 400
LEFT JOIN generic_mapping_values gmv ON gmv.mapping_table_id = @mapping_table_id_uk_probable_limit_coal
	AND clm1_value = sb.[source_book_id]
	AND clm2_value = sb2.[source_book_id]
	AND clm3_value = sb1.[source_book_id]
	AND clm4_value = sb3.[source_book_id]
	AND clm5_value = sdv.value_id
WHERE gmv.generic_mapping_values_id IS NULL
