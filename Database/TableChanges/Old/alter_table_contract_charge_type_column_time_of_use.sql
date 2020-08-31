IF COL_LENGTH('contract_charge_type', 'time_of_use') IS NULL
BEGIN
    ALTER TABLE contract_charge_type ADD time_of_use VARCHAR(10) NULL
END
GO

IF COL_LENGTH('contract_charge_type', 'payment_calendar') IS NULL
BEGIN
    ALTER TABLE contract_charge_type ADD payment_calendar VARCHAR(10) NULL
END
GO

IF COL_LENGTH('contract_charge_type', 'pnl_date') IS NULL
BEGIN
    ALTER TABLE contract_charge_type ADD pnl_date VARCHAR(10) NULL
END
GO

IF COL_LENGTH('contract_charge_type', 'pnl_calendar') IS NULL
BEGIN
    ALTER TABLE contract_charge_type ADD pnl_calendar VARCHAR(10) NULL
END
GO

IF COL_LENGTH('contract_charge_type', 'settlement_date') IS NULL
BEGIN
    ALTER TABLE contract_charge_type ADD settlement_date DATETIME NULL
END
GO

IF COL_LENGTH('contract_charge_type', 'settlement_calendar') IS NULL
BEGIN
    ALTER TABLE contract_charge_type ADD settlement_calendar VARCHAR(10) NULL
END
GO

IF COL_LENGTH('contract_charge_type', 'effective_date') IS NULL
BEGIN
    ALTER TABLE contract_charge_type ADD effective_date DATETIME NULL
END
GO

IF COL_LENGTH('contract_charge_type', 'aggregration_level') IS NULL
BEGIN
    ALTER TABLE contract_charge_type ADD aggregration_level VARCHAR(10) NULL
END
GO