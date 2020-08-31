IF OBJECT_ID('tempdb..#temp_generic_mapping') IS NOT NULL
    DROP TABLE #temp_generic_mapping
    
DECLARE @mapping_table_id INT
SELECT @mapping_table_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'UK Gas Dynamic Limit';

DELETE gmv 
FROM generic_mapping_values gmv
INNER JOIN generic_mapping_header gmh ON gmv.mapping_table_id = gmh.mapping_table_id
WHERE gmh.mapping_name = 'UK Gas Dynamic Limit'

--Internal Portfolio = SELECT source_book_id, source_book_name FROM source_book where source_system_book_type_value_id=50
--counterpartygroup SELECT source_book_id, source_book_name FROM source_book where source_system_book_type_value_id=51
-- instrument type SELECT source_book_id, source_book_name FROM source_book where source_system_book_type_value_id=52
-- projection index  SELECT source_book_id, source_book_name FROM source_book WHERE source_system_book_type_value_id = 53
-- mtm SELECT 'y' AS id, 'Yes' AS Name UNION ALL SELECT 'n', 'No'

-- Insert missing Data for Internal Portfolio
IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'v8_UKS_IGATA_GAS')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'v8_UKS_IGATA_GAS', 50, 'v8_UKS_IGATA_GAS','v8_UKS_IGATA_GAS'
END
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 50 WHERE source_system_book_id = 'v8_UKS_IGATA_GAS'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'v8_UKS_IGENSPRD')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'v8_UKS_IGENSPRD', 50, 'v8_UKS_IGENSPRD','v8_UKS_IGENSPRD'
END
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 50 WHERE source_system_book_id = 'v8_UKS_IGENSPRD'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'v8_NGIPHYSICAL_IM')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'v8_NGIPHYSICAL_IM', 50, 'v8_NGIPHYSICAL_IM','v8_NGIPHYSICAL_IM'
END
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 50 WHERE source_system_book_id = 'v8_NGIPHYSICAL_IM'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'NG_PROMPT_GBP')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'NG_PROMPT_GBP', 50, 'NG_PROMPT_GBP','NG_PROMPT_GBP'
END
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 50 WHERE source_system_book_id = 'NG_PROMPT_GBP'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'NG_UK_DELTA_2_GBP')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'NG_UK_DELTA_2_GBP', 50, 'NG_UK_DELTA_2_GBP','NG_UK_DELTA_2_GBP'
END
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 50 WHERE source_system_book_id = 'NG_UK_DELTA_2_GBP'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'NG_UK_LEG_GBP')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'NG_UK_LEG_GBP', 50, 'NG_UK_LEG_GBP','NG_UK_LEG_GBP'
END
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 50 WHERE source_system_book_id = 'NG_UK_LEG_GBP'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'UKP FS 1')
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
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 50 WHERE source_system_book_id = 'UKP FS 1'
END

-- Insert missing Data for Internal Portfolio END

-- Insert missing Data for Counterparty Group

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'External')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'External', 51, 'External','External'
END
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 51 WHERE source_system_book_id = 'External'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'RWEN_HEDGED_ITEM')
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
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 51 WHERE source_system_book_id = 'RWEN_HEDGED_ITEM'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'RWE nPower')
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
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 51 WHERE source_system_book_id = 'RWE nPower'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'NPOWER LTD')
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
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 51 WHERE source_system_book_id = 'NPOWER LTD'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'NPOWER NORTHERN LTD LE')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'NPOWER NORTHERN LTD LE', 51, 'NPOWER NORTHERN LTD LE','NPOWER NORTHERN LTD LE'
END
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 51 WHERE source_system_book_id = 'NPOWER NORTHERN LTD LE'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'NPOWER COGEN LE')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'NPOWER COGEN LE', 51, 'NPOWER COGEN LE','NPOWER COGEN LE'
END
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 51 WHERE source_system_book_id = 'NPOWER COGEN LE'
END
-- Insert missing Data for Counterparty Group END
-- Insert missing Data for Instrument Type
IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'COMM-PHYS')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'COMM-PHYS', 52, 'COMM-PHYS','COMM-PHYS'
END
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 52 WHERE source_system_book_id = 'COMM-PHYS'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'GAS-FWD-STD-P')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'GAS-FWD-STD-P', 52, 'GAS-FWD-STD-P','GAS-FWD-STD-P'
END
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 52 WHERE source_system_book_id = 'GAS-FWD-STD-P'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'GAS-FWD-P')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'GAS-FWD-P', 52, 'GAS-FWD-P','GAS-FWD-P'
END
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 52 WHERE source_system_book_id = 'GAS-FWD-P'
END
-- Insert missing Data for Instrument Type END

-- Insert missing Data for Projection_index_group 

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'Natural Gas')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'Natural Gas', 53, 'Natural Gas','Natural Gas'
END
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 53 WHERE source_system_book_id = 'Natural Gas'
END
-- Insert missing Data for Projection_index_group END
CREATE TABLE #temp_generic_mapping ([internal_portfolio] VARCHAR(100), [counterparty_group] VARCHAR(100), [instrument_type] VARCHAR(100), [projection_index_group] VARCHAR(100), [mtm] VARCHAR(100))

INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('v8_UKS_IGATA_GAS', 'External', 'COMM-PHYS', 'Natural Gas', 'Yes')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('v8_UKS_IGENSPRD', 'RWEN_HEDGED_ITEM', 'COMM-PHYS', 'Natural Gas', 'Yes')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('v8_NGIPHYSICAL_IM', 'RWE nPower', 'COMM-PHYS', 'Natural Gas', 'Yes')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('v8_NGIPHYSICAL_IM', 'NPOWER LTD', 'COMM-PHYS', 'Natural Gas', 'Yes')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('NG_PROMPT_GBP', 'NPOWER NORTHERN LTD LE', 'GAS-FWD-STD-P', 'Natural Gas', 'Yes')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('NG_UK_DELTA_2_GBP', 'NPOWER COGEN LE', 'GAS-FWD-STD-P', 'Natural Gas', 'Yes')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('NG_UK_DELTA_2_GBP', 'NPOWER NORTHERN LTD LE', 'GAS-FWD-P', 'Natural Gas', 'Yes')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('NG_UK_LEG_GBP', 'NPOWER NORTHERN LTD LE', 'GAS-FWD-STD-P', 'Natural Gas', 'Yes')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('UKP FS 1', 'RWEN_HEDGED_ITEM', 'GAS-FWD-STD-P', 'Natural Gas', 'Yes')
INSERT INTO #temp_generic_mapping ([internal_portfolio], [counterparty_group], [instrument_type], [projection_index_group], [mtm]) VALUES ('UKP FS 1', 'RWEN_HEDGED_ITEM', 'GAS-FWD-P', 'Natural Gas', 'Yes')

INSERT INTO generic_mapping_values
(
	mapping_table_id,
	clm1_value,
	clm2_value,
	clm3_value,
	clm4_value,	
	clm5_value
)
SELECT	@mapping_table_id [mapping_table_id], 
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
LEFT JOIN generic_mapping_values gmv ON gmv.mapping_table_id = @mapping_table_id
	AND clm1_value = sb.source_book_id
	AND clm2_value = sb1.source_book_id
	AND clm3_value = sb2.source_book_id
	AND clm4_value = sb3.source_book_id
	AND clm5_value = CASE WHEN tgm.[mtm] = 'Yes' THEN 'y' ELSE 'n' END
WHERE gmv.generic_mapping_values_id IS NULL
