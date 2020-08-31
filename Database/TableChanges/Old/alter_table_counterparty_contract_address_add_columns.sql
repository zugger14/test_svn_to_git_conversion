IF COL_LENGTH('counterparty_contract_address', 'contract_date') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address ADD contract_date DATETIME
END
GO

IF COL_LENGTH('counterparty_contract_address', 'contract_status') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address ADD contract_status INT
END
GO

IF COL_LENGTH('counterparty_contract_address', 'contract_active') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address ADD contract_active CHAR(1)
END
GO

IF COL_LENGTH('counterparty_contract_address', 'cc_mail') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address ADD cc_mail VARCHAR(5000)
END
GO

IF COL_LENGTH('counterparty_contract_address', 'bcc_mail') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address ADD bcc_mail VARCHAR(5000)
END
GO

IF COL_LENGTH('counterparty_contract_address', 'remittance_to') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address ADD remittance_to VARCHAR(5000)
END
GO

IF COL_LENGTH('counterparty_contract_address', 'cc_remittance') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address ADD cc_remittance VARCHAR(5000)
END
GO

IF COL_LENGTH('counterparty_contract_address', 'bcc_remittance') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address ADD bcc_remittance VARCHAR(5000)
END
GO

IF COL_LENGTH('counterparty_contract_address', 'billing_start_month') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address ADD billing_start_month INT
END
GO
