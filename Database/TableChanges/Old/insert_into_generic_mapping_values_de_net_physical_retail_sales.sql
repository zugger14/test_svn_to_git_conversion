IF OBJECT_ID('tempdb..#temp_generic_mapping') IS NOT NULL
    DROP TABLE #temp_generic_mapping
    
DECLARE @mapping_table_id_de_net_physical_retail_sales INT
SELECT @mapping_table_id_de_net_physical_retail_sales = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'DE Net Physical Retail Sales';

DELETE gmv 
FROM generic_mapping_values gmv
INNER JOIN generic_mapping_header gmh ON gmv.mapping_table_id = gmh.mapping_table_id
WHERE gmh.mapping_name = 'DE Net Physical Retail Sales'

-- SELECT source_book_id, source_book_name FROM source_book where source_system_book_type_value_id=50
--SELECT source_book_id, source_book_name FROM source_book where source_system_book_type_value_id=52
--SELECT source_curve_def_id, curve_name FROM source_price_curve_def
-- select 1 id,'Include' Descp union all select 2 id,'Exclude' Descp

IF OBJECT_ID('tempdb..#temp_generic_mapping') IS NOT NULL
	DROP TABLE #temp_generic_mapping

CREATE TABLE #temp_generic_mapping ([internal_portfolio] VARCHAR(100),[instrument_type] VARCHAR(100), [curve] VARCHAR(100), include_exclude VARCHAR(100))

INSERT INTO #temp_generic_mapping ([internal_portfolio], [instrument_type], [curve], include_exclude) VALUES ('', 'PWR-FWD-P', 'vPWR_DE_P','Include')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [instrument_type], [curve], include_exclude) VALUES ('', 'PWR-FWD-STD-P', 'vPWR_DE_P','Include')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [instrument_type], [curve], include_exclude) VALUES ('v8_CCX_BB_RWE_ENERGY', '', '','Exclude')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [instrument_type], [curve], include_exclude) VALUES ('', 'PWR-PHYS', 'v8_EIS_valuation','Include')

INSERT INTO generic_mapping_values
(
	mapping_table_id,
	clm1_value,
	clm2_value,
	clm3_value,
	clm4_value
)
SELECT	@mapping_table_id_de_net_physical_retail_sales [mapping_table_id], 
		sb.[source_book_id],
		sb1.[source_book_id],
		spcd.source_curve_def_id,
		CASE WHEN tgm.include_exclude = 'Include' THEN 1 ELSE 2 END
FROM #temp_generic_mapping tgm
LEFT JOIN source_book sb ON tgm.internal_portfolio = sb.[source_book_name] AND sb.source_system_book_type_value_id=50
LEFT JOIN source_book sb1 ON tgm.[instrument_type] = sb1.[source_book_name] AND sb1.source_system_book_type_value_id=52
LEFT JOIN source_price_curve_def spcd ON tgm.[curve] = spcd.curve_name
LEFT JOIN generic_mapping_values gmv ON gmv.mapping_table_id = @mapping_table_id_de_net_physical_retail_sales
	AND clm1_value = sb.[source_book_id]
	AND clm2_value = sb1.[source_book_id]
	AND clm3_value = spcd.source_curve_def_id
	AND clm4_value = CASE WHEN tgm.include_exclude = 'Include' THEN 1 ELSE 2 END
WHERE gmv.generic_mapping_values_id IS NULL
