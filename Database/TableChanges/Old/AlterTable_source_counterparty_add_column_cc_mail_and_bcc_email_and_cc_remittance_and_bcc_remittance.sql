IF COL_LENGTH('source_counterparty', 'cc_email') IS NULL
BEGIN
    ALTER TABLE source_counterparty ADD cc_email varchar(5000)  
END
GO

IF COL_LENGTH('source_counterparty', 'bcc_email') IS NULL
BEGIN
    ALTER TABLE source_counterparty ADD bcc_email varchar(5000) 
END
GO

IF COL_LENGTH('source_counterparty', 'cc_remittance') IS NULL
BEGIN
    ALTER TABLE source_counterparty ADD cc_remittance varchar(5000) 
END
GO

IF COL_LENGTH('source_counterparty', 'bcc_remittance') IS NULL
BEGIN
    ALTER TABLE source_counterparty ADD bcc_remittance varchar(5000) 
END
GO

IF COL_LENGTH('source_counterparty', 'email_remittance_to') IS NULL
BEGIN
    ALTER TABLE source_counterparty ADD email_remittance_to varchar(5000) 
END
GO