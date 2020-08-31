IF NOT EXISTS (SELECT 'x' FROM INFORMATION_SCHEMA.columns WHERE table_name LIKE 'source_deal_header' AND column_name LIKE 'timezone_id')
BEGIN
	ALTER TABLE source_deal_header ADD timezone_id INT
END