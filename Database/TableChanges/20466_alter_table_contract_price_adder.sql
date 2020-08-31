IF COL_LENGTH('contract_price', 'adder') IS NOT NULL
BEGIN
    ALTER TABLE contract_price ALTER COLUMN adder FLOAT NULL
END
GO