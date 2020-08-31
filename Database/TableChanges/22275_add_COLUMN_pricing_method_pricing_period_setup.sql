
IF COL_LENGTH('pricing_period_setup', 'pricing_method') IS  NULL
BEGIN
	ALTER TABLE pricing_period_setup add  pricing_method INT 
END