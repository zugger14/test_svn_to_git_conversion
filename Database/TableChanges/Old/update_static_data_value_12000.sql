UPDATE static_data_value
SET code = 'Checked' WHERE value_id = 12000
	
UPDATE static_data_value
SET code = 'UnChecked' WHERE value_id = 12001


--SELECT * FROM source_price_curve_def WHERE block_type IS NOT NULL AND block_type<>12001
--SELECT * FROM source_deal_header WHERE block_type IS NOT NULL AND block_type<>12001


UPDATE source_price_curve_def SET block_type=12000 WHERE block_type IS NOT NULL AND block_type<>12001
UPDATE source_deal_header SET block_type=12000 WHERE block_type IS NOT NULL AND block_type<>12001


--SELECT * FROM dbo.static_data_value WHERE TYPE_ID=12000

--SELECT * FROM static_data_value WHERE TYPE_ID=12000 AND value_id NOT IN(12000,12001)
DELETE FROM static_data_value WHERE TYPE_ID=12000 AND value_id NOT IN(12000,12001)

--SELECT * FROM dbo.hour_block_term ORDER BY term_date

EXEC spa_generate_hour_block_term NULL,2000,2030

