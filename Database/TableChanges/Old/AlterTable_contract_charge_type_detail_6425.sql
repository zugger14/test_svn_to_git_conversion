IF COL_LENGTH('contract_charge_type_detail', 'time_of_use') IS NULL
BEGIN
    ALTER TABLE contract_charge_type_detail ADD time_of_use INT NULL
END
GO

IF COL_LENGTH('contract_charge_type_detail', 'payment_calendar') IS NULL
BEGIN
    ALTER TABLE contract_charge_type_detail ADD payment_calendar INT NULL
END
GO

IF COL_LENGTH('contract_charge_type_detail', 'pnl_date') IS NULL
BEGIN
    ALTER TABLE contract_charge_type_detail ADD pnl_date INT NULL
END
GO

IF COL_LENGTH('contract_charge_type_detail', 'pnl_calendar') IS NULL
BEGIN
    ALTER TABLE contract_charge_type_detail ADD pnl_calendar INT NULL
END
GO

IF COL_LENGTH('contract_charge_type_detail', 'settlement_date') IS NULL
BEGIN
    ALTER TABLE contract_charge_type_detail ADD settlement_date DATETIME NULL 
END
GO

IF COL_LENGTH('contract_charge_type_detail', 'settlement_calendar') IS NULL
BEGIN
    ALTER TABLE contract_charge_type_detail ADD settlement_calendar INT NULL
END
GO

IF COL_LENGTH('contract_charge_type_detail', 'effective_date') IS NULL
BEGIN
    ALTER TABLE contract_charge_type_detail ADD effective_date DATETIME NULL
END
GO

IF COL_LENGTH('contract_charge_type_detail', 'aggregation_level') IS NULL
BEGIN
    ALTER TABLE contract_charge_type_detail ADD aggregation_level INT NULL
END
GO