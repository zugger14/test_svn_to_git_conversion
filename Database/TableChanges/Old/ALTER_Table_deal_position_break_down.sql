
IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name ='deal_position_break_down' AND column_name='location_id')
ALTER TABLE deal_position_break_down ADD location_id	FLOAT

IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name ='deal_position_break_down' AND column_name='volume_uom_id')
ALTER TABLE deal_position_break_down ADD volume_uom_id	int

IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name ='deal_position_break_down' AND column_name='commodity_id')
ALTER TABLE deal_position_break_down ADD commodity_id	int

IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name ='deal_position_break_down' AND column_name='phy_fin_flag')
ALTER TABLE deal_position_break_down ADD phy_fin_flag	int

IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name ='deal_position_break_down' AND column_name='del_term_start')
ALTER TABLE deal_position_break_down ADD del_term_start	float

IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name ='deal_position_break_down' AND column_name='fin_term_start')
ALTER TABLE deal_position_break_down ADD fin_term_start	int

IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name ='deal_position_break_down' AND column_name='fin_expiration_date')
ALTER TABLE deal_position_break_down ADD fin_expiration_date	float

IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name ='deal_position_break_down' AND column_name='del_vol_multiplier')
ALTER TABLE deal_position_break_down ADD del_vol_multiplier	float

IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name ='deal_position_break_down' AND column_name='fin_term_end')
ALTER TABLE deal_position_break_down ADD fin_term_end	float
