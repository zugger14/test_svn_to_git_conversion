
IF COL_LENGTH('contract_formula_rounding_options', 'set_mid') IS NULL
BEGIN

	ALTER TABLE contract_formula_rounding_options ADD set_mid BIT
	ALTER TABLE contract_formula_rounding_options ADD final_round_value int
	ALTER TABLE contract_formula_rounding_options ADD lag_round_value int
	PRINT 'Column contract_formula_rounding_options.set_mid added.'
END
ELSE
BEGIN
	PRINT 'Column contract_formula_rounding_options.set_mid already exists.'
END
GO


IF COL_LENGTH('contract_formula_rounding_options', 'mid') IS NULL
BEGIN

	ALTER TABLE contract_formula_rounding_options ADD mid BIT
		PRINT 'Column contract_formula_rounding_options.mid added.'
END
ELSE
BEGIN
	PRINT 'Column contract_formula_rounding_options.mid already exists.'
END
GO



IF COL_LENGTH('contract_formula_rounding_options', 'bid_ask_round_value') IS NULL
BEGIN
	ALTER TABLE contract_formula_rounding_options ADD bid_ask_round_value int
		PRINT 'Column contract_formula_rounding_options.bid_ask_round_value added.'
END
ELSE
BEGIN
	PRINT 'Column contract_formula_rounding_options.bid_ask_round_value already exists.'
END
GO