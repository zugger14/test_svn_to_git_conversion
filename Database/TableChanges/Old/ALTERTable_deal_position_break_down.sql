IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name ='deal_position_break_down' AND column_name='derived_curve_id')
	ALTER TABLE deal_position_break_down ADD derived_curve_id	FLOAT NULL
