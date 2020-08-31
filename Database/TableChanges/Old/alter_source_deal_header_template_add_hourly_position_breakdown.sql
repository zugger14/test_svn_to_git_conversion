IF NOT EXISTS (SELECT 'x' FROM information_schema.columns WHERE TABLE_NAME = 'source_deal_header_template'
AND column_name = 'hourly_position_breakdown')
ALTER TABLE source_deal_header_template ADD hourly_position_breakdown CHAR(1)