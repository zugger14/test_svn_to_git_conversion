IF COL_LENGTH('source_counterparty_audit', 'cc_email') IS NULL
BEGIN
    ALTER TABLE source_counterparty_audit ADD cc_email varchar(5000)
END
GO

IF COL_LENGTH('source_counterparty_audit', 'bcc_email') IS NULL
BEGIN
    ALTER TABLE source_counterparty_audit ADD bcc_email varchar(5000)
END
GO

IF COL_LENGTH('source_counterparty_audit', 'cc_remittance') IS NULL
BEGIN
    ALTER TABLE source_counterparty_audit ADD cc_remittance varchar(5000)
END
GO

IF COL_LENGTH('source_counterparty_audit', 'bcc_remittance') IS NULL
BEGIN
    ALTER TABLE source_counterparty_audit ADD bcc_remittance varchar(5000)
END
GO

IF COL_LENGTH('source_counterparty_audit', 'email_remittance_to') IS NULL
BEGIN
    ALTER TABLE source_counterparty_audit ADD email_remittance_to varchar(5000)
END
GO

IF COL_LENGTH('source_counterparty_audit', 'delivery_method') IS NULL
BEGIN
    ALTER TABLE source_counterparty_audit ADD delivery_method INT
END
GO

IF COL_LENGTH('source_counterparty_audit', 'tax_id') IS NULL
BEGIN
    ALTER TABLE source_counterparty_audit ADD tax_id INT
END
GO