IF NOT EXISTS (SELECT 'x' FROM INFORMATION_SCHEMA.columns WHERE table_name='source_deal_header' AND column_name='term_frequency')
	ALTER TABLE source_deal_header ADD term_frequency CHAR(1)
