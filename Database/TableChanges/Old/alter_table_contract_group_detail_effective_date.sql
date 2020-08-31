--Added the new column name 'contract_template' for contract_group_detail table  
IF COL_LENGTH('contract_group_detail', 'contract_template') IS NULL
BEGIN
    ALTER TABLE contract_group_detail ADD contract_template INT NULL
END
GO

--Added the new column 'contract_component_template' for contract_group_detail table
IF COL_LENGTH('contract_group_detail', 'contract_component_template') IS NULL
BEGIN
    ALTER TABLE contract_group_detail ADD contract_component_template INT NULL
END
GO

--Added the new column 'radio_automatic_manual' for contract_group_detail table
IF COL_LENGTH('contract_group_detail', 'radio_automatic_manual') IS NULL
BEGIN
    ALTER TABLE contract_group_detail ADD radio_automatic_manual CHAR(1) NULL
END
GO

--Added the new column 'settlement_date' for contract_group_detail table
IF COL_LENGTH('contract_group_detail', 'settlement_date') IS NULL
BEGIN
    ALTER TABLE contract_group_detail ADD settlement_date DATETIME NULL
END
GO

--Added the new column 'settlement_calendar' for contract_group_detail table
IF COL_LENGTH('contract_group_detail', 'settlement_calendar') IS NULL
BEGIN
    ALTER TABLE contract_group_detail ADD settlement_calendar INT NULL
END
GO

--Added the new column 'effective_date' for contract_group_detail table
IF COL_LENGTH('contract_group_detail', 'effective_date') IS NULL
BEGIN
    ALTER TABLE contract_group_detail ADD effective_date DATETIME NULL
END
GO