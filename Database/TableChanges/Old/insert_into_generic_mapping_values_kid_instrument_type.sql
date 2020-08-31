IF OBJECT_ID('tempdb..#temp_generic_mapping') IS NOT NULL
    DROP TABLE #temp_generic_mapping
    
DECLARE @mapping_table_id_kid_instrument_type INT
SELECT @mapping_table_id_kid_instrument_type = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'KID-Instrument Type';

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'PWR-SWAP-F')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'PWR-SWAP-F', 52, 'PWR-SWAP-F','PWR-SWAP-F'
END
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 52 WHERE source_system_book_id = 'PWR-SWAP-F'
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

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'PWR-SWAP-STD-F')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'PWR-SWAP-STD-F', 52, 'PWR-SWAP-STD-F','PWR-SWAP-STD-F'
END
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 52 WHERE source_system_book_id = 'PWR-SWAP-STD-F'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'EM-FWD-P')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'EM-FWD-P', 52, 'EM-FWD-P','EM-FWD-P'
END
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 52 WHERE source_system_book_id = 'EM-FWD-P'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'REN-FWD-P')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'REN-FWD-P', 52, 'REN-FWD-P','REN-FWD-P'
END
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 52 WHERE source_system_book_id = 'REN-FWD-P'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'WTH-SWAP-F')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'WTH-SWAP-F', 52, 'WTH-SWAP-F','WTH-SWAP-F'
END
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 52 WHERE source_system_book_id = 'WTH-SWAP-F'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'CARBON ETO')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'CARBON ETO', 52, 'CARBON ETO','CARBON ETO'
END
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 52 WHERE source_system_book_id = 'CARBON ETO'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'ENGY-EXCH-OPT')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'ENGY-EXCH-OPT', 52, 'ENGY-EXCH-OPT','ENGY-EXCH-OPT'
END
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 52 WHERE source_system_book_id = 'ENGY-EXCH-OPT'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'WTH-SWAP')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'WTH-SWAP', 52, 'WTH-SWAP','WTH-SWAP'
END
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 52 WHERE source_system_book_id = 'WTH-SWAP'
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_system_id = 2 AND source_system_book_id = 'PWR-OPT-PUT-Y-P')
BEGIN
	INSERT INTO source_book
	(
	source_system_id
	, source_system_book_id
	, source_system_book_type_value_id
	, source_book_name
	, source_book_desc)
	SELECT 2, 'PWR-OPT-PUT-Y-P', 52, 'PWR-OPT-PUT-Y-P','PWR-OPT-PUT-Y-P'
END
ELSE
BEGIN
	UPDATE source_book SET source_system_book_type_value_id = 52 WHERE source_system_book_id = 'PWR-OPT-PUT-Y-P'
END

DELETE gmv 
FROM generic_mapping_values gmv
INNER JOIN generic_mapping_header gmh ON gmv.mapping_table_id = gmh.mapping_table_id
WHERE gmh.mapping_name = 'KID-Instrument Type'

IF OBJECT_ID('tempdb..#temp_generic_mapping') IS NOT NULL
	DROP TABLE #temp_generic_mapping
CREATE TABLE #temp_generic_mapping ([kid_instrument_type] VARCHAR(100), [product_kid] VARCHAR(100), [type_of_product] VARCHAR(100))

INSERT INTO #temp_generic_mapping ([kid_instrument_type], [product_kid], [type_of_product]) VALUES ('PWR-SWAP-F', 'Swap', 4)
INSERT INTO #temp_generic_mapping ([kid_instrument_type], [product_kid], [type_of_product]) VALUES ('GAS-FWD-P', 'Forward/FRA', 3)
INSERT INTO #temp_generic_mapping ([kid_instrument_type], [product_kid], [type_of_product]) VALUES ('PWR-SWAP-STD-F', 'Swap', 4)
INSERT INTO #temp_generic_mapping ([kid_instrument_type], [product_kid], [type_of_product]) VALUES ('EM-FWD-P', 'Forward/FRA', 3)
INSERT INTO #temp_generic_mapping ([kid_instrument_type], [product_kid], [type_of_product]) VALUES ('REN-FWD-P', 'Forward/FRA', 3)
INSERT INTO #temp_generic_mapping ([kid_instrument_type], [product_kid], [type_of_product]) VALUES ('WTH-SWAP-F', 'Sonstige', 22)
INSERT INTO #temp_generic_mapping ([kid_instrument_type], [product_kid], [type_of_product]) VALUES ('CARBON ETO', 'Call-Option', 1)
INSERT INTO #temp_generic_mapping ([kid_instrument_type], [product_kid], [type_of_product]) VALUES ('ENGY-EXCH-OPT', 'Call-Option', 1)
INSERT INTO #temp_generic_mapping ([kid_instrument_type], [product_kid], [type_of_product]) VALUES ('WTH-SWAP', 'Sonstige', 22)
INSERT INTO #temp_generic_mapping ([kid_instrument_type], [product_kid], [type_of_product]) VALUES ('PWR-OPT-PUT-Y-P', 'Put-Option', 2)

INSERT INTO generic_mapping_values
(
	mapping_table_id,
	clm1_value,
	clm2_value,	
	clm3_value
)
SELECT	@mapping_table_id_kid_instrument_type [mapping_table_id], 
		sb.source_book_id,
		tgm.[product_kid], 
		tgm.[type_of_product]
FROM #temp_generic_mapping tgm
LEFT JOIN source_book sb ON tgm.[kid_instrument_type] = sb.source_system_book_id AND sb.source_system_book_type_value_id = 52
LEFT JOIN generic_mapping_values gmv ON gmv.mapping_table_id = @mapping_table_id_kid_instrument_type
	AND clm1_value = sb.source_book_id
	AND clm2_value = tgm.[product_kid]
	AND clm3_value = tgm.[type_of_product]
WHERE gmv.generic_mapping_values_id IS NULL
