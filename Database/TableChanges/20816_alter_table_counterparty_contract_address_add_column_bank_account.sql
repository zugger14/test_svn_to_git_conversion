IF NOT EXISTS (SELECT 1 FROM sys.[columns] c WHERE c.name = 'bank_account' AND c.[object_id] = OBJECT_ID(N'counterparty_contract_address'))
BEGIN
	ALTER TABLE counterparty_contract_address ADD bank_account INT CONSTRAINT FK_counterparty_contract_address_counterparty_bank_info FOREIGN KEY (bank_account) REFERENCES  counterparty_bank_info(bank_id)
END
ELSE 
	PRINT 'bank_account column already exist.'