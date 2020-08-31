IF COL_LENGTH('contract_price', 'adder') IS NULL
BEGIN
    ALTER TABLE contract_price ADD adder INT NULL
END
GO

IF COL_LENGTH('contract_price', 'fix_price') IS NULL
BEGIN
    ALTER TABLE contract_price ADD fix_price FLOAT NULL
END
GO

IF COL_LENGTH('contract_price', 'effective_date') IS NULL
BEGIN
    ALTER TABLE contract_price ADD effective_date DATETIME NULL
END
GO