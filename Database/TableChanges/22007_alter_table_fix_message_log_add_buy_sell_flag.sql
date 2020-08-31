IF COL_LENGTH('fix_message_log','buy_sell_flag') IS NULL 
	ALTER TABLE fix_message_log ADD buy_sell_flag VARCHAR(50)
GO
	