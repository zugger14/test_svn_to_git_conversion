IF OBJECT_ID('tempdb..#temp_generic_mapping') IS NOT NULL
    DROP TABLE #temp_generic_mapping
    
DECLARE @mapping_table_id_uk_power_dynamic_limit INT
SELECT @mapping_table_id_uk_power_dynamic_limit = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'UK Power Dynamic Limit';

DELETE gmv 
FROM generic_mapping_values gmv
INNER JOIN generic_mapping_header gmh ON gmv.mapping_table_id = gmh.mapping_table_id
WHERE gmh.mapping_name = 'UK Power Dynamic Limit'

--Internal Portfolio = SELECT source_book_id, source_book_name FROM source_book where source_system_book_type_value_id=50
--counterpartygroup SELECT source_book_id, source_book_name FROM source_book where source_system_book_type_value_id=51
-- instrument type SELECT source_book_id, source_book_name FROM source_book where source_system_book_type_value_id=52
-- projection index  SELECT source_book_id, source_book_name FROM source_book WHERE source_system_book_type_value_id = 53
-- mtm SELECT 'y' AS id, 'Yes' AS Name UNION ALL SELECT 'n', 'No'

-- Insert missing Data for Internal Portfolio
IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_book_type_value_id = 50 AND source_system_book_id = 'v8_UKP_IFE')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'v8_UKP_IFE', 50, 'v8_UKP_IFE','v8_UKP_IFE'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_book_type_value_id = 50 AND source_system_book_id = 'v8_UKP_IFE1')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'v8_UKP_IFE1', 50, 'v8_UKP_IFE1','v8_UKP_IFE1'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_book_type_value_id = 50 AND source_system_book_id = 'v8_UKP_IFE2')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'v8_UKP_IFE2', 50, 'v8_UKP_IFE2','v8_UKP_IFE2'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_book_type_value_id = 50 AND source_system_book_id = 'v8_UKP_IFE3')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'v8_UKP_IFE3', 50, 'v8_UKP_IFE3','v8_UKP_IFE3'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_book_type_value_id = 50 AND source_system_book_id = 'v8_UKP_IFE4')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'v8_UKP_IFE4', 50, 'v8_UKP_IFE4','v8_UKP_IFE4'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_book_type_value_id = 50 AND source_system_book_id = 'v8_UKP_IFE5')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'v8_UKP_IFE5', 50, 'v8_UKP_IFE5','v8_UKP_IFE5'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_book_type_value_id = 50 AND source_system_book_id = 'v8_UKP_IFE10')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'v8_UKP_IFE10', 50, 'v8_UKP_IFE10','v8_UKP_IFE10'
END
-- Insert missing Data for Internal Portfolio END

-- Insert missing Data for Counterparty Group

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_book_type_value_id = 51 AND source_system_book_id = 'NPOWER (MANX)')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'NPOWER (MANX)', 51, 'NPOWER (MANX)','NPOWER (MANX)'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_book_type_value_id = 51 AND source_system_book_id = 'RWE nPower')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'RWE nPower', 51, 'RWE nPower','RWE nPower'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_book_type_value_id = 51 AND source_system_book_id = 'NPOWER LTD')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'NPOWER LTD', 51, 'NPOWER LTD','NPOWER LTD'
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
-- Insert missing Data for Counterparty Group END

-- Insert missing Data for Instrument Type
IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_book_type_value_id = 52 AND source_system_book_id = 'PWR-PHYS')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'PWR-PHYS', 52, 'PWR-PHYS','PWR-PHYS'
END
-- Insert missing Data for Instrument Type END

-- Insert missing Data for Projection_index_group 

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_book_type_value_id = 53 AND source_system_book_id = 'Electricity')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'Electricity', 53, 'Electricity','Electricity'
END
-- Insert missing Data for Projection_index_group END

IF OBJECT_ID('tempdb..#temp_generic_mapping') IS NOT NULL
	DROP TABLE #temp_generic_mapping

CREATE TABLE #temp_generic_mapping ([internal_portfolio] VARCHAR(100), [counterparty_group] VARCHAR(100), [instrument_type] VARCHAR(100), [projection_index_group] VARCHAR(100), [mtm] VARCHAR(100))

INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('v8_UKP_IFE', 'NPOWER (MANX)', 'PWR-PHYS', 'Electricity', 'Yes')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('v8_UKP_IFE1', 'NPOWER (MANX)', 'PWR-PHYS', 'Electricity', 'Yes')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('v8_UKP_IFE2', 'NPOWER (MANX)', 'PWR-PHYS', 'Electricity', 'Yes')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('v8_UKP_IFE3', 'NPOWER (MANX)', 'PWR-PHYS', 'Electricity', 'Yes')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('v8_UKP_IFE4', 'NPOWER (MANX)', 'PWR-PHYS', 'Electricity', 'Yes')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('v8_UKP_IFE5', 'NPOWER (MANX)', 'PWR-PHYS', 'Electricity', 'Yes')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('v8_UKP_IFE10', 'RWE nPower', 'PWR-PHYS', 'Electricity', 'Yes')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('v8_UKP_IFE10', 'NPOWER LTD', 'PWR-PHYS', 'Electricity', 'Yes')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('v8_UKP_IFE10', 'RWEN_HEDGED_ITEM', 'PWR-PHYS', 'Electricity', 'Yes')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('v8_UKP_IFE2', 'RWE nPower', 'PWR-PHYS', 'Electricity', 'Yes')

INSERT INTO generic_mapping_values
(
	mapping_table_id,
	clm1_value,
	clm2_value,
	clm3_value,
	clm4_value,	
	clm5_value
)
SELECT	@mapping_table_id_uk_power_dynamic_limit [mapping_table_id], 
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
LEFT JOIN generic_mapping_values gmv ON gmv.mapping_table_id = @mapping_table_id_uk_power_dynamic_limit
	AND clm1_value = sb.source_book_id
	AND clm2_value = sb1.source_book_id
	AND clm3_value = sb2.source_book_id
	AND clm4_value = sb3.source_book_id
	AND clm5_value = CASE WHEN tgm.[mtm] = 'Yes' THEN 'y' ELSE 'n' END
WHERE gmv.generic_mapping_values_id IS NULL
