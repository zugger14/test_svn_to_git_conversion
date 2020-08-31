IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE NAME = N'options_calc_method' AND Object_ID = Object_ID(N'source_deal_header_template'))
BEGIN
	ALTER TABLE source_deal_header_template ADD options_calc_method INT
END
ELSE 
	PRINT 'options_calc_method column already exist in source_deal_header_template.'