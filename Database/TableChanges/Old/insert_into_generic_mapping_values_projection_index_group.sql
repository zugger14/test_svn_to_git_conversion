IF OBJECT_ID('tempdb..#temp_generic_mapping') IS NOT NULL
    DROP TABLE #temp_generic_mapping
    
DECLARE @mapping_table_id INT
SELECT @mapping_table_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'Projection Index Group';

DELETE gmv 
FROM generic_mapping_values gmv
INNER JOIN generic_mapping_header gmh ON gmv.mapping_table_id = gmh.mapping_table_id
WHERE gmh.mapping_name = 'Projection Index Group'

--SELECT source_book_id, source_book_name FROM source_book WHERE source_system_book_type_value_id = 53
--SELECT source_uom_id, uom_id FROM  source_uom

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'Electricity')
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
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 53 WHERE source_system_book_id = 'Electricity'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'Emissions')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'Emissions', 53, 'Emissions','Emissions'
END
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 53 WHERE source_system_book_id = 'Emissions'
END

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
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 53 WHERE source_system_book_id = 'Natural Gas'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'Coal')
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
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 53 WHERE source_system_book_id = 'Coal'
END

IF NOT EXISTS (SELECT 1 FROM source_uom WHERE uom_id = 'tCO2e')
BEGIN
	INSERT INTO source_uom
	(
	source_system_id
	, uom_id
	, uom_name
	, uom_desc)
	SELECT 2, 'tCO2e', 'tCO2e', 'tCO2e'
END

IF NOT EXISTS (SELECT 1 FROM source_uom WHERE uom_id = 'MWh')
BEGIN
	INSERT INTO source_uom
	(
	source_system_id
	, uom_id
	, uom_name
	, uom_desc)
	SELECT 2, 'MWh', 'MWh', 'MWh'
END

IF NOT EXISTS (SELECT 1 FROM source_uom WHERE uom_id = 'MT')
BEGIN
	INSERT INTO source_uom
	(
	source_system_id
	, uom_id
	, uom_name
	, uom_desc)
	SELECT 2, 'MT', 'MT', 'MT'
END

CREATE TABLE #temp_generic_mapping([projection_index_group] VARCHAR(100), [uom] VARCHAR(100));
INSERT INTO #temp_generic_mapping ([projection_index_group],  [uom]) VALUES ('Electricity','Mwh');
INSERT INTO #temp_generic_mapping ([projection_index_group],  [uom]) VALUES ('Natural Gas','Mwh');
INSERT INTO #temp_generic_mapping ([projection_index_group],  [uom]) VALUES ('Coal','MT');
INSERT INTO #temp_generic_mapping ([projection_index_group],  [uom]) VALUES ('Emissions','tCO2e');

INSERT INTO generic_mapping_values
(
	mapping_table_id,
	clm1_value,
	clm2_value	
)
SELECT	@mapping_table_id [mapping_table_id], 
		sb.source_book_id, 
		su.source_uom_id		
FROM #temp_generic_mapping tgm
LEFT JOIN source_book sb ON tgm.[projection_index_group] = sb.source_system_book_id AND source_system_book_type_value_id = 53
LEFT JOIN source_uom su ON tgm.[uom] = su.uom_id
LEFT JOIN generic_mapping_values gmv ON gmv.mapping_table_id = @mapping_table_id
AND clm1_value = sb.source_book_id
AND clm2_value = su.source_uom_id
WHERE gmv.generic_mapping_values_id IS NULL