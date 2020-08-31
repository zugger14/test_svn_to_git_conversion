
IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name ='report_hourly_position_deal' AND column_name='hr25')
ALTER TABLE report_hourly_position_deal ADD hr25 FLOAT

IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name ='report_hourly_position_profile' AND column_name='hr25')
ALTER TABLE report_hourly_position_profile ADD hr25	int

IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name ='report_hourly_position_breakdown' AND column_name='hr25')
ALTER TABLE report_hourly_position_breakdown ADD hr25	int

