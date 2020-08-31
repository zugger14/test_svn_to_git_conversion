IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'source_deal_header_template' AND column_name = 'description4')
BEGIN
	ALTER TABLE source_deal_header_template ADD description4 VARCHAR(50)
END