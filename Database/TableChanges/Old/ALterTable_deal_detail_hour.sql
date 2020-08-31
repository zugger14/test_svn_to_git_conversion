
IF NOT EXISTS (SELECT 'x' FROM information_schema.[COLUMNS]  WHERE TABLE_NAME ='deal_detail_hour' AND COLUMN_NAME ='block_type')
	ALTER table deal_detail_hour ADD block_type INT

IF NOT EXISTS (SELECT 'x' FROM information_schema.[COLUMNS]  WHERE TABLE_NAME ='deal_detail_hour' AND COLUMN_NAME ='block_define_id')
	ALTER table deal_detail_hour ADD block_define_id INT




