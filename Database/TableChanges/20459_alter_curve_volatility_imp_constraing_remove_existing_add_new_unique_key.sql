IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE TABLE_NAME = 'curve_volatility_imp' AND CONSTRAINT_NAME = 'PK_Volatility_Imp_Unq')
BEGIN
	ALTER TABLE curve_volatility_imp DROP CONSTRAINT PK_Volatility_Imp_Unq
END

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE TABLE_NAME = 'curve_volatility_imp' AND CONSTRAINT_NAME = 'UNQ_Volatility_Imp_Unq')
BEGIN
	ALTER TABLE curve_volatility_imp
	ADD CONSTRAINT UNQ_Volatility_Imp_Unq UNIQUE (as_of_date, curve_id, term, curve_source_value_id, strike, option_type, exercise_type)
END