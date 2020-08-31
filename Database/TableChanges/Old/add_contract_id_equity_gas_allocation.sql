IF COL_LENGTH('equity_gas_allocation','contract_id') IS NULL 
ALTER TABLE dbo.equity_gas_allocation ADD contract_id int