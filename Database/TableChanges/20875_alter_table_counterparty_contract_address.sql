IF COL_LENGTH('counterparty_contract_address', 'payment_rule') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address ADD payment_rule INT
	PRINT 'Column ''payment_rule'' inserted successfully.'
END
ELSE 
	PRINT 'Column ''payment_rule'' already exists.'