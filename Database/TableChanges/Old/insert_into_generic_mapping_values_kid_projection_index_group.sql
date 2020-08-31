IF OBJECT_ID('tempdb..#temp_generic_mapping') IS NOT NULL
    DROP TABLE #temp_generic_mapping
    
DECLARE @mapping_table_id_kid_projection_index_group INT
SELECT @mapping_table_id_kid_projection_index_group = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'KID-Projection Index Group';

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'Base Metal')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'Base Metal', 53, 'Base Metal','Base Metal'
END
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 53 WHERE source_system_book_id = 'Base Metal'
END

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

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'Gas Liquid')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'Gas Liquid', 53, 'Gas Liquid','Gas Liquid'
END
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 53 WHERE source_system_book_id = 'Gas Liquid'
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

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'Crude Oil')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'Crude Oil', 53, 'Crude Oil','Crude Oil'
END
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 53 WHERE source_system_book_id = 'Crude Oil'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'Refined Product')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'Refined Product', 53, 'Refined Product','Refined Product'
END
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 53 WHERE source_system_book_id = 'Refined Product'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'Index')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'Index', 53, 'Index','Index'
END
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 53 WHERE source_system_book_id = 'Index'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'None_FT')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'None_FT', 53, 'None_FT','None_FT'
END
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 53 WHERE source_system_book_id = 'None_FT'
END

DELETE gmv 
FROM generic_mapping_values gmv
INNER JOIN generic_mapping_header gmh ON gmv.mapping_table_id = gmh.mapping_table_id
WHERE gmh.mapping_name = 'KID-Projection Index Group'


IF OBJECT_ID('tempdb..#temp_generic_mapping') IS NOT NULL
	DROP TABLE #temp_generic_mapping

CREATE TABLE #temp_generic_mapping ([projection_index_group] VARCHAR(100), [commodity_kid] VARCHAR(100), [type_of_product] VARCHAR(100))

INSERT INTO #temp_generic_mapping ([projection_index_group], [commodity_kid], [type_of_product]) VALUES ('Base Metal', 'Aluminium', 'A')
INSERT INTO #temp_generic_mapping ([projection_index_group], [commodity_kid], [type_of_product]) VALUES ('Electricity', 'Power', 'S')
INSERT INTO #temp_generic_mapping ([projection_index_group], [commodity_kid], [type_of_product]) VALUES ('Emissions', 'Carbon', 'C')
INSERT INTO #temp_generic_mapping ([projection_index_group], [commodity_kid], [type_of_product]) VALUES ('Coal', 'Coal', 'K')
INSERT INTO #temp_generic_mapping ([projection_index_group], [commodity_kid], [type_of_product]) VALUES ('Gas Liquid', 'Gas', 'G')
INSERT INTO #temp_generic_mapping ([projection_index_group], [commodity_kid], [type_of_product]) VALUES ('Natural Gas', 'Gas','G')
INSERT INTO #temp_generic_mapping ([projection_index_group], [commodity_kid], [type_of_product]) VALUES ('Crude Oil', 'Oil', 'O')
INSERT INTO #temp_generic_mapping ([projection_index_group], [commodity_kid], [type_of_product]) VALUES ('Refined Product', 'Oil', 'O')
INSERT INTO #temp_generic_mapping ([projection_index_group], [commodity_kid], [type_of_product]) VALUES ('Index', 'Others', 'So')
INSERT INTO #temp_generic_mapping ([projection_index_group], [commodity_kid], [type_of_product]) VALUES ('None_FT', 'Others', 'So')


INSERT INTO generic_mapping_values
(
	mapping_table_id,
	clm1_value,
	clm2_value,	
	clm3_value
)
SELECT	@mapping_table_id_kid_projection_index_group [mapping_table_id], 
		sb.source_book_id,
		tgm.[commodity_kid], 
		tgm.[type_of_product]
FROM #temp_generic_mapping tgm
LEFT JOIN source_book sb ON tgm.[projection_index_group] = sb.source_system_book_id AND sb.source_system_book_type_value_id = 53
LEFT JOIN generic_mapping_values gmv ON gmv.mapping_table_id = @mapping_table_id_kid_projection_index_group
	AND clm1_value = sb.source_book_id
	AND clm2_value = tgm.[commodity_kid]
	AND clm3_value = tgm.[type_of_product]
WHERE gmv.generic_mapping_values_id IS NULL
