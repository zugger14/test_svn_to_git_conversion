IF COL_LENGTH('equity_gas_allocation', 'route_id') IS NULL
BEGIN
    ALTER TABLE equity_gas_allocation ADD route_id INT
END
GO