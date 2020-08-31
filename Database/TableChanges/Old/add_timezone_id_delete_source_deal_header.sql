IF NOT EXISTS (SELECT 'x' FROM information_schema.columns WHERE table_name = 'delete_source_deal_header' AND column_name = 'timezone_id')
	ALTER TABLE delete_source_deal_header ADD timezone_id INT
