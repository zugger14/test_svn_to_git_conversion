IF COL_LENGTH('contract_group_audit', 'payment_days') IS NULL
BEGIN
    ALTER TABLE contract_group_audit ADD payment_days INT
END
GO

IF COL_LENGTH('contract_group_audit', 'settlement_calendar') IS NULL
BEGIN
    ALTER TABLE contract_group_audit ADD settlement_calendar INT
END
GO

IF COL_LENGTH('contract_group_audit', 'settlement_days') IS NULL
BEGIN
    ALTER TABLE contract_group_audit ADD settlement_days INT
END
GO

IF COL_LENGTH('contract_group_audit', 'settlement_rule') IS NULL
BEGIN
    ALTER TABLE contract_group_audit ADD settlement_rule INT
END
GO

IF COL_LENGTH('contract_group_audit', 'settlement_date') IS NULL
BEGIN
    ALTER TABLE contract_group_audit ADD settlement_date INT
END
GO

IF COL_LENGTH('contract_group_audit', 'invoice_report_template') IS NULL
BEGIN
    ALTER TABLE contract_group_audit ADD invoice_report_template INT
END
GO

IF COL_LENGTH('contract_group_audit', 'netting_template') IS NULL
BEGIN
    ALTER TABLE contract_group_audit ADD netting_template INT
END
GO

IF COL_LENGTH('contract_group_audit', 'self_billing') IS NULL
BEGIN
    ALTER TABLE contract_group_audit ADD self_billing CHAR(1)
END
GO

IF COL_LENGTH('contract_group_audit', 'neting_rule') IS NULL
BEGIN
    ALTER TABLE contract_group_audit ADD neting_rule CHAR(1)
END
GO
