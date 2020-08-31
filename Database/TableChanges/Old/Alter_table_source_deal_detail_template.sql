
IF COL_LENGTH('source_deal_detail_template', 'adder_currency_id') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD adder_currency_id INT
	PRINT 'Column source_deal_detail_template.adder_currency_id added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.adder_currency_id already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'booked') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD booked CHAR
	PRINT 'Column source_deal_detail_template.booked added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.booked already exists.'
END
GO


IF COL_LENGTH('source_deal_detail_template', 'capacity') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD capacity NUMERIC(38, 17)
	PRINT 'Column source_deal_detail_template.capacity added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.capacity already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'day_count_id') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD day_count_id INT
	PRINT 'Column source_deal_detail_template.day_count_id added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.day_count_id already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'deal_detail_description') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD deal_detail_description VARCHAR(100)
	PRINT 'Column source_deal_detail_template.deal_detail_description added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.deal_detail_description already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'fixed_cost') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD fixed_cost NUMERIC(38, 17)
	PRINT 'Column source_deal_detail_template.fixed_cost added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.fixed_cost already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'fixed_cost_currency_id') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD fixed_cost_currency_id INT
	PRINT 'Column source_deal_detail_template.fixed_cost_currency_id added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.fixed_cost_currency_id already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'formula_currency_id') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD formula_currency_id INT
	PRINT 'Column source_deal_detail_template.formula_currency_id added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.formula_currency_id already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'formula_curve_id') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD formula_curve_id INT
	PRINT 'Column source_deal_detail_template.formula_curve_id added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.formula_curve_id already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'formula_id') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD formula_id INT
	PRINT 'Column source_deal_detail_template.formula_id added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.formula_id already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'multiplier') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD multiplier NUMERIC(38, 17)
	PRINT 'Column source_deal_detail_template.multiplier added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.multiplier already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'option_strike_price') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD option_strike_price NUMERIC(38, 17)
	PRINT 'Column source_deal_detail_template.option_strike_price added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.option_strike_price already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'price_adder') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD price_adder NUMERIC(38, 17)
	PRINT 'Column source_deal_detail_template.price_adder added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.price_adder already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'price_adder_currency2') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD price_adder_currency2 INT
	PRINT 'Column source_deal_detail_template.price_adder_currency2 added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.price_adder_currency2 already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'price_adder2') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD price_adder2 NUMERIC(38, 17)
	PRINT 'Column source_deal_detail_template.price_adder2 added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.price_adder2 already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'price_multiplier') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD price_multiplier NUMERIC(38, 17)
	PRINT 'Column source_deal_detail_template.price_multiplier added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.price_multiplier already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'process_deal_status') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD process_deal_status INT
	PRINT 'Column source_deal_detail_template.process_deal_status added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.process_deal_status already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'settlement_date') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD settlement_date DATETIME
	PRINT 'Column source_deal_detail_template.settlement_date added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.settlement_date already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'settlement_uom') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD settlement_uom INT
	PRINT 'Column source_deal_detail_template.settlement_uom added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.settlement_uom already exists.'
END
GO


IF COL_LENGTH('source_deal_detail_template', 'settlement_volume') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD settlement_volume FLOAT
	PRINT 'Column source_deal_detail_template.settlement_volume added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.settlement_volume already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'total_volume') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD total_volume NUMERIC(38, 17)
	PRINT 'Column source_deal_detail_template.total_volume added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.total_volume already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'volume_left') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD volume_left FLOAT
	PRINT 'Column source_deal_detail_template.volume_left added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.volume_left already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'volume_multiplier2') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD volume_multiplier2 NUMERIC(38, 17)
	PRINT 'Column source_deal_detail_template.volume_multiplier2 added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.volume_multiplier2 already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'term_start') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD term_start DATETIME
	PRINT 'Column source_deal_detail_template.term_start added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.term_start already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'term_end') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD term_end DATETIME
	PRINT 'Column source_deal_detail_template.term_end added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.term_end already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'contract_expiration_date') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD contract_expiration_date DATETIME
	PRINT 'Column source_deal_detail_template.contract_expiration_date added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.contract_expiration_date already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'fixed_price') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD fixed_price NUMERIC(38,17)
	PRINT 'Column source_deal_detail_template.fixed_price added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.fixed_price already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'fixed_price_currency_id') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD fixed_price_currency_id INT
	PRINT 'Column source_deal_detail_template.fixed_price_currency_id added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.fixed_price_currency_id already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'deal_volume') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template ADD deal_volume NUMERIC(38,17)
	PRINT 'Column source_deal_detail_template.deal_volume added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_template.deal_volume already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'source_deal_header_id') IS NOT NULL
BEGIN
	ALTER TABLE source_deal_detail_template DROP COLUMN source_deal_header_id 
	PRINT 'Column source_deal_detail_template.source_deal_header_id has been deleted.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'source_deal_detail_id') IS NOT NULL
BEGIN
	ALTER TABLE source_deal_detail_template DROP COLUMN source_deal_detail_id 
	PRINT 'Column source_deal_detail_template.source_deal_detail_id has been deleted.'
END
GO