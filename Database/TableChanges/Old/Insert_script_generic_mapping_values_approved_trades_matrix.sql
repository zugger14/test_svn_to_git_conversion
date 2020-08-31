IF OBJECT_ID('tempdb..#temp_generic_mapping') IS NOT NULL
    DROP TABLE #temp_generic_mapping
IF OBJECT_ID('tempdb..#tenor') IS NOT NULL
    DROP TABLE #tenor
    
DECLARE @mapping_table_id INT
SELECT @mapping_table_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'Approved Trades Matrix';

DELETE gmv 
FROM generic_mapping_values gmv
INNER JOIN generic_mapping_header gmh ON gmv.mapping_table_id = gmh.mapping_table_id
WHERE gmh.mapping_name = 'Approved Trades Matrix'

CREATE TABLE #tenor ([Value_id] INT, [tenor] VARCHAR(100));
INSERT INTO #tenor ([Value_id] , [tenor]) VALUES (1, 'All Tenor');
INSERT INTO #tenor ([Value_id] , [tenor]) VALUES (2, '2 years');
INSERT INTO #tenor ([Value_id] , [tenor]) VALUES (3, '4 years');
INSERT INTO #tenor ([Value_id] , [tenor]) VALUES (4, 'BOM');

CREATE TABLE #temp_generic_mapping([trader] VARCHAR(100), [deal_type] VARCHAR(100) , [template] VARCHAR(100), [tenor] VARCHAR(100));
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Proxy, K.','Swap','Power Fixed for Float Swap','BOM');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Proxy, K.','Swap','Gas Fixed For Float Swap','BOM');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Wilkins, D.','Physical','Power Physical Fixed','All tenor');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Wilkins, D.','Physical','Power Physical Index','All tenor');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Wilkins, D.','Swap','Power Fixed for Float Swap','4 years');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Wilkins, D.','Transportation','Capacity NG','All tenor');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Wilkins, D.','Transmission','Power Transmission','All tenor');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Wilkins, D.','Physical','Gas Physical Fixed','All tenor');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Wilkins, D.','Swap','Gas Fixed For Float Swap','4 years');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Wilkins, D.','Swap','Gas Index Swap','4 years');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Wilkins, D.','Physical','Gas Futures','4 years');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Vaughn, R.','Physical','Power Physical Fixed','All tenor');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Vaughn, R.','Physical','Power Physical Index','All tenor');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Vaughn, R.','Swap','Power Fixed for Float Swap','4 years');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Vaughn, R.','Transportation','Capacity NG','All tenor');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Vaughn, R.','Transmission','Power Transmission','All tenor');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Vaughn, R.','Physical','Gas Physical Fixed','All tenor');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Vaughn, R.','Swap','Gas Fixed For Float Swap','4 years');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Vaughn, R.','Swap','Gas Index Swap','4 years');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Vaughn, R.','Physical','Gas Futures','4 years');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Webster, S.','Physical','Power Physical Fixed','All tenor');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Webster, S.','Physical','Power Physical Index','All tenor');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Webster, S.','Swap','Power Fixed for Float Swap','4 years');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Webster, S.','Transportation','Capacity NG','All tenor');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Webster, S.','Transmission','Power Transmission','All tenor');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Webster, S.','Physical','Gas Physical Fixed','All tenor');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Webster, S.','Swap','Gas Fixed For Float Swap','4 years');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Webster, S.','Swap','Gas Index Swap','4 years');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Webster, S.','Physical','Gas Futures','4 years');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Cheshire, C.','Physical','Power Physical Fixed','All tenor');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Cheshire, C.','Physical','Power Physical Index','All tenor');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Cheshire, C.','Swap','Power Fixed for Float Swap','4 years');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Cheshire, C.','Transportation','Capacity NG','All tenor');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Cheshire, C.','Transmission','Power Transmission','All tenor');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Cheshire, C.','Physical','Gas Physical Fixed','All tenor');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Cheshire, C.','Swap','Gas Fixed For Float Swap','4 years');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Cheshire, C.','Swap','Gas Index Swap','4 years');
INSERT INTO #temp_generic_mapping ([trader],  [deal_type],  [template],  [tenor]) VALUES ('Cheshire, C.','Physical','Gas Futures','4 years');

INSERT INTO generic_mapping_values
(
	mapping_table_id,
	clm1_value,
	clm2_value,
	clm3_value,
	clm4_value		
)
SELECT	@mapping_table_id [mapping_table_id], 
		st.source_trader_id, 
		sdt.source_deal_type_id, 
		sdht.template_id, 
		t.Value_id
FROM #temp_generic_mapping tgm
INNER JOIN source_traders st ON tgm.[trader] = st.trader_id
INNER JOIN source_deal_type sdt ON tgm.[deal_type] = sdt.deal_type_id
INNER JOIN source_deal_header_template sdht ON sdht.template_name = tgm.[template]
INNER JOIN #tenor t ON t.tenor = tgm.[tenor]
LEFT JOIN generic_mapping_values gmv ON gmv.mapping_table_id = @mapping_table_id
AND clm1_value = st.source_trader_id
AND clm2_value = sdt.source_deal_type_id
AND clm3_value = sdht.template_id
AND clm4_value = t.Value_id
WHERE gmv.generic_mapping_values_id IS NULL