SELECT DISTINCT sml.source_major_location_ID,
       pspcm.location_group_id
FROM   pratos_source_price_curve_map pspcm
       INNER JOIN source_major_location sml
            ON  sml.location_name = pspcm.location_group_id

UPDATE pspcm
SET pspcm.location_group_id = sml.source_major_location_ID
FROM   pratos_source_price_curve_map pspcm
       INNER JOIN source_major_location sml
            ON  sml.location_name = pspcm.location_group_id
            
SELECT DISTINCT sdv.value_id,
       pspcm1.region
FROM   pratos_source_price_curve_map pspcm1
       INNER JOIN static_data_value sdv ON  sdv.code = pspcm1.region
       
UPDATE pspcm1
SET pspcm1.region = sdv.value_id
FROM   pratos_source_price_curve_map pspcm1
       INNER JOIN static_data_value sdv ON  sdv.code = pspcm1.region
       
SELECT DISTINCT sdv.value_id,
       pspcm2.grid_value_id
FROM   pratos_source_price_curve_map pspcm2
       INNER JOIN static_data_value sdv ON  sdv.code = pspcm2.grid_value_id
       
UPDATE pspcm2
SET pspcm2.grid_value_id = sdv.value_id
FROM   pratos_source_price_curve_map pspcm2
       INNER JOIN static_data_value sdv ON  sdv.code = pspcm2.grid_value_id                      