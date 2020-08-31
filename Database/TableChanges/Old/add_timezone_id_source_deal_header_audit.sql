IF NOT EXISTS (SELECT 'x' FROM information_schema.columns WHERE table_name = 'source_deal_header_audit' AND column_name = 'timezone_id')
	ALTER TABLE source_deal_header_audit ADD timezone_id INT
