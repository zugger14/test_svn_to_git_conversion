DELETE FROM  counterparty_credit_info
WHERE counterparty_credit_info.Counterparty_id NOT IN (SELECT MIN(b.Counterparty_id)
FROM   counterparty_credit_info b
GROUP BY b.Counterparty_id);

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'Unique_Counterparty_id')
BEGIN
	ALTER TABLE counterparty_credit_info
	ADD CONSTRAINT Unique_Counterparty_id UNIQUE (Counterparty_id)
END

--ALTER TABLE counterparty_credit_info drop CONSTRAINT 'Unique_Counterparty_id'

