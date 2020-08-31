IF OBJECT_ID('tempdb..#temp_generic_mapping') IS NOT NULL
    DROP TABLE #temp_generic_mapping
    
DECLARE @mapping_table_id_uk_coal_dynamic_limit INT
SELECT @mapping_table_id_uk_coal_dynamic_limit = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'UK Coal Dynamic Limit';

DELETE gmv 
FROM generic_mapping_values gmv
INNER JOIN generic_mapping_header gmh ON gmv.mapping_table_id = gmh.mapping_table_id
WHERE gmh.mapping_name = 'UK Coal Dynamic Limit'

--Internal Portfolio = SELECT source_book_id, source_book_name FROM source_book where source_system_book_type_value_id=50
--counterpartygroup SELECT source_book_id, source_book_name FROM source_book where source_system_book_type_value_id=51
-- instrument type SELECT source_book_id, source_book_name FROM source_book where source_system_book_type_value_id=52
-- projection index  SELECT source_book_id, source_book_name FROM source_book WHERE source_system_book_type_value_id = 53
-- mtm SELECT 'y' AS id, 'Yes' AS Name UNION ALL SELECT 'n', 'No'

-- Insert missing Data for Internal Portfolio
IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_book_type_value_id = 50 AND source_system_book_id = 'CF_UKC_I')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'CF_UKC_I', 50, 'CF_UKC_I','CF_UKC_I'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_book_type_value_id = 50 AND source_system_book_id = 'UKP FS 1')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'UKP FS 1', 50, 'UKP FS 1','UKP FS 1'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_book_type_value_id = 50 AND source_system_book_id = 'CF_UKC_NV_PROP_COAL_TF')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'CF_UKC_NV_PROP_COAL_TF', 50, 'CF_UKC_NV_PROP_COAL_TF','CF_UKC_NV_PROP_COAL_TF'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_book_type_value_id = 50 AND source_system_book_id = 'CF_UKC_T')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'CF_UKC_T', 50, 'CF_UKC_T','CF_UKC_T'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_book_type_value_id = 50 AND source_system_book_id = 'CF_UKC_T_API2_TECHNICAL')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'CF_UKC_T_API2_TECHNICAL', 50, 'CF_UKC_T_API2_TECHNICAL','CF_UKC_T_API2_TECHNICAL'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_book_type_value_id = 50 AND source_system_book_id = 'CF_UKC_T_COAL_OPTIONS_ARA')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'CF_UKC_T_COAL_OPTIONS_ARA', 50, 'CF_UKC_T_COAL_OPTIONS_ARA','CF_UKC_T_COAL_OPTIONS_ARA'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_book_type_value_id = 50 AND source_system_book_id = 'CF_UKC_T_CSX_API2_SPEC')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'CF_UKC_T_CSX_API2_SPEC', 50, 'CF_UKC_T_CSX_API2_SPEC','CF_UKC_T_CSX_API2_SPEC'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_book_type_value_id = 50 AND source_system_book_id = 'CF_UKC_T_DES_ARA_CRAPS_0')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'CF_UKC_T_DES_ARA_CRAPS_0', 50, 'CF_UKC_T_DES_ARA_CRAPS_0','CF_UKC_T_DES_ARA_CRAPS_0'
END
-- Insert missing Data for Internal Portfolio END

-- Insert missing Data for Counterparty Group

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_book_type_value_id = 51 AND source_system_book_id = 'Interdesk')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'Interdesk', 51, 'Interdesk','Interdesk'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_book_type_value_id = 51 AND source_system_book_id = 'Intradesk')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'Intradesk', 51, 'Intradesk','Intradesk'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_book_type_value_id = 51 AND source_system_book_id = 'RWEN_HEDGED_ITEM')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'RWEN_HEDGED_ITEM', 51, 'RWEN_HEDGED_ITEM','RWEN_HEDGED_ITEM'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_book_type_value_id = 51 AND source_system_book_id = 'InterPE_HEDGED_ITEM')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'InterPE_HEDGED_ITEM', 51, 'InterPE_HEDGED_ITEM','InterPE_HEDGED_ITEM'
END

-- Insert missing Data for Counterparty Group END
-- Insert missing Data for Instrument Type
IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_book_type_value_id = 52 AND source_system_book_id = 'COAL-SWAP-F')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'COAL-SWAP-F', 52, 'COAL-SWAP-F','COAL-SWAP-F'
END
-- Insert missing Data for Instrument Type END

-- Insert missing Data for Projection_index_group 

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_book_type_value_id = 53 AND source_system_book_id = 'Coal')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'Coal', 53, 'Coal','Coal'
END
-- Insert missing Data for Projection_index_group END

IF OBJECT_ID('tempdb..#temp_generic_mapping') IS NOT NULL
	DROP TABLE #temp_generic_mapping

CREATE TABLE #temp_generic_mapping ([internal_portfolio] VARCHAR(100), [counterparty_group] VARCHAR(100), [instrument_type] VARCHAR(100), [projection_index_group] VARCHAR(100), [mtm] VARCHAR(100))

INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('CF_UKC_I', 'RWEN_HEDGED_ITEM', 'COAL-SWAP-F', 'Coal', 'Yes')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('UKP FS 1', 'RWEN_HEDGED_ITEM', 'COAL-SWAP-F', 'Coal', 'Yes')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('CF_UKC_I', 'Interdesk', 'COAL-SWAP-F', 'Coal', 'Yes')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('CF_UKC_I', 'Intradesk', 'COAL-SWAP-F', 'Coal', 'Yes')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('CF_UKC_NV_PROP_COAL_TF', 'InterPE_HEDGED_ITEM', 'COAL-SWAP-F', 'Coal', 'Yes')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('CF_UKC_T', 'InterPE_HEDGED_ITEM', 'COAL-SWAP-F', 'Coal', 'Yes')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('CF_UKC_T_API2_TECHNICAL', 'InterPE_HEDGED_ITEM', 'COAL-SWAP-F', 'Coal', 'Yes')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('CF_UKC_T_COAL_OPTIONS_ARA', 'InterPE_HEDGED_ITEM', 'COAL-SWAP-F', 'Coal', 'Yes')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('CF_UKC_T_CSX_API2_SPEC', 'InterPE_HEDGED_ITEM', 'COAL-SWAP-F', 'Coal', 'Yes')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('CF_UKC_T_DES_ARA_CRAPS_0', 'InterPE_HEDGED_ITEM', 'COAL-SWAP-F', 'Coal', 'Yes')

INSERT INTO generic_mapping_values
(
	mapping_table_id,
	clm1_value,
	clm2_value,
	clm3_value,
	clm4_value,	
	clm5_value
)
SELECT	@mapping_table_id_uk_coal_dynamic_limit [mapping_table_id], 
		sb.source_book_id, 
		sb1.source_book_id,
		sb2.source_book_id,
		sb3.source_book_id,		
		CASE WHEN tgm.[mtm] = 'Yes' THEN 'y' ELSE 'n' END mtm
FROM #temp_generic_mapping tgm
LEFT JOIN source_book sb ON tgm.[internal_portfolio] = sb.source_book_name AND sb.source_system_book_type_value_id = 50
LEFT JOIN source_book sb1 ON tgm.[counterparty_group] = sb1.source_book_name AND sb1.source_system_book_type_value_id = 51
LEFT JOIN source_book sb2 ON tgm.[instrument_type] = sb2.source_book_name AND sb2.source_system_book_type_value_id = 52
LEFT JOIN source_book sb3 ON tgm.[projection_index_group] = sb3.source_book_name AND sb3.source_system_book_type_value_id = 53
LEFT JOIN generic_mapping_values gmv ON gmv.mapping_table_id = @mapping_table_id_uk_coal_dynamic_limit
	AND clm1_value = sb.source_book_id
	AND clm2_value = sb1.source_book_id
	AND clm3_value = sb2.source_book_id
	AND clm4_value = sb3.source_book_id
	AND clm5_value = CASE WHEN tgm.[mtm] = 'Yes' THEN 'y' ELSE 'n' END
WHERE gmv.generic_mapping_values_id IS NULL
