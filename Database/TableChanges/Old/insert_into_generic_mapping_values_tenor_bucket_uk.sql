IF OBJECT_ID('tempdb..#temp_generic_mapping') IS NOT NULL
    DROP TABLE #temp_generic_mapping
    
DECLARE @mapping_table_id_tenor_bucket_uk INT
SELECT @mapping_table_id_tenor_bucket_uk = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'Tenor Bucket UK';

DELETE gmv 
FROM generic_mapping_values gmv
INNER JOIN generic_mapping_header gmh ON gmv.mapping_table_id = gmh.mapping_table_id
WHERE gmh.mapping_name = 'Tenor Bucket UK'

--index SELECT source_curve_def_id, curve_name FROM source_price_curve_def
--SELECT bucket_header_id, bucket_header_name FROM risk_tenor_bucket_header WHERE bucket_header_name LIKE '%UK'

-- Insert missing Data for Tenor Bucket UK
IF NOT EXISTS (SELECT 1 FROM risk_tenor_bucket_header WHERE bucket_header_name = 'Power UK')
BEGIN
	INSERT INTO risk_tenor_bucket_header (bucket_header_name) SELECT 'Power UK'
END

IF NOT EXISTS (SELECT 1 FROM risk_tenor_bucket_header WHERE bucket_header_name = 'Coal UK')
BEGIN
	INSERT INTO risk_tenor_bucket_header (bucket_header_name) SELECT 'Coal UK'
END

IF NOT EXISTS (SELECT 1 FROM risk_tenor_bucket_header WHERE bucket_header_name = 'Gas UK')
BEGIN
	INSERT INTO risk_tenor_bucket_header (bucket_header_name) SELECT 'Gas UK'
END
-- Insert missing Data for Tenor Bucket UK END

IF OBJECT_ID('tempdb..#temp_generic_mapping') IS NOT NULL
	DROP TABLE #temp_generic_mapping

CREATE TABLE #temp_generic_mapping ([index] VARCHAR(100), [tenor_bucket_uk] VARCHAR(100))

INSERT INTO #temp_generic_mapping ([index], [tenor_bucket_uk]) VALUES ('vPWR_UK_P', 'Power UK')
INSERT INTO #temp_generic_mapping ([index], [tenor_bucket_uk]) VALUES ('CO_API_2', 'Coal UK')
INSERT INTO #temp_generic_mapping ([index], [tenor_bucket_uk]) VALUES ('NG_NBP_P_M', 'Gas UK')

INSERT INTO generic_mapping_values
(
	mapping_table_id,
	clm1_value,
	clm2_value	
)
SELECT	@mapping_table_id_tenor_bucket_uk [mapping_table_id], 
		spcd.source_curve_def_id, 
		rtbh.bucket_header_id
FROM #temp_generic_mapping tgm
LEFT JOIN source_price_curve_def spcd ON tgm.[index] = spcd.curve_name
LEFT JOIN risk_tenor_bucket_header rtbh ON tgm.[tenor_bucket_uk] = rtbh.bucket_header_name
LEFT JOIN generic_mapping_values gmv ON gmv.mapping_table_id = @mapping_table_id_tenor_bucket_uk
	AND clm1_value = spcd.source_curve_def_id
	AND clm2_value = rtbh.bucket_header_id
WHERE gmv.generic_mapping_values_id IS NULL
