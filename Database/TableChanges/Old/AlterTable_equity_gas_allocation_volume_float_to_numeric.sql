IF COL_LENGTH('equity_gas_allocation', 'volume') IS NOT NULL
BEGIN
    ALTER TABLE equity_gas_allocation ALTER COLUMN volume NUMERIC(38, 20)
END