IF NOT EXISTS (SELECT 1 FROM sys.[columns] c WHERE c.name = N'contract_id' AND OBJECT_ID = OBJECT_ID(N'counterparty_epa_account'))
BEGIN
	ALTER TABLE counterparty_epa_account ADD contract_id INT CONSTRAINT [FK_counterparty_epa_account_contract_group] FOREIGN KEY (contract_id) REFERENCES contract_group(contract_id)
END
ELSE
	PRINT 'contract_id column already exist.'