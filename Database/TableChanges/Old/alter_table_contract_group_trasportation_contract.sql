IF COL_LENGTH('contract_group', 'transportation_contract') IS NULL
BEGIN
    ALTER TABLE contract_group ADD transportation_contract CHAR(1) NULL
END
GO

IF COL_LENGTH('contract_group', 'pipeline') IS NULL
BEGIN
    ALTER TABLE contract_group ADD pipeline varchar(100) NULL
END
GO

IF COL_LENGTH('contract_group', 'flow_start_date') IS NULL
BEGIN
    ALTER TABLE contract_group ADD flow_start_date DATETIME NULL
END
GO

IF COL_LENGTH('contract_group', 'flow_end_date') IS NULL
BEGIN
    ALTER TABLE contract_group ADD flow_end_date DATETIME NULL
END
GO

IF COL_LENGTH('contract_group', 'settlement_rule') IS NULL
BEGIN
    ALTER TABLE contract_group ADD settlement_rule INT NULL
END
GO

IF COL_LENGTH('contract_group', 'path') IS NULL
BEGIN
    ALTER TABLE contract_group ADD [path] INT NULL
END
GO

IF COL_LENGTH('contract_group', 'capacity_release') IS NULL
BEGIN
    ALTER TABLE contract_group ADD capacity_release CHAR(1) NULL
END
GO

IF COL_LENGTH('contract_group', 'firm') IS NULL
BEGIN
    ALTER TABLE contract_group ADD firm CHAR(1) NULL
END
GO

IF COL_LENGTH('contract_group', 'interruptible') IS NULL
BEGIN
    ALTER TABLE contract_group ADD interruptible CHAR(1) NULL
END
GO

IF COL_LENGTH('contract_group', 'base_load') IS NULL
BEGIN
    ALTER TABLE contract_group ADD base_load CHAR(1) NULL
END
GO

IF COL_LENGTH('contract_group', 'financial_rate_fees') IS NULL
BEGIN
    ALTER TABLE contract_group ADD financial_rate_fees INT NULL
END
GO