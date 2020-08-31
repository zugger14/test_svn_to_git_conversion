IF COL_LENGTH('contract_formula_rounding_options', 'create_user') IS NULL
BEGIN
    ALTER TABLE contract_formula_rounding_options ADD [create_user] VARCHAR(50)DEFAULT dbo.FNADBUser()
END


IF COL_LENGTH('contract_formula_rounding_options', 'create_ts') IS NULL
BEGIN
    ALTER TABLE contract_formula_rounding_options ADD [create_ts] DATETIME DEFAULT GETDATE()
END


IF COL_LENGTH('contract_formula_rounding_options', 'update_user') IS NULL

BEGIN
    ALTER TABLE contract_formula_rounding_options ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('contract_formula_rounding_options', 'update_ts') IS NULL
BEGIN
    ALTER TABLE contract_formula_rounding_options ADD [update_ts] DATETIME NULL
END