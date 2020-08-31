IF COL_LENGTH('master_view_counterparty_contacts', 'email_cc') IS NULL
BEGIN
    ALTER TABLE master_view_counterparty_contacts ADD email_cc VARCHAR(500)
END
GO

IF COL_LENGTH('master_view_counterparty_contacts', 'email_bcc') IS NULL
BEGIN
    ALTER TABLE master_view_counterparty_contacts ADD email_bcc VARCHAR(500)
END
GO