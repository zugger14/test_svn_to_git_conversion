
IF COL_LENGTH('contract_group', 'invoice_report_template') IS NULL
BEGIN
    ALTER TABLE contract_group ADD invoice_report_template INT
END
GO

IF COL_LENGTH('contract_group', 'neting_rule') IS NULL
BEGIN
    ALTER TABLE contract_group ADD neting_rule CHAR(1)
END
GO




