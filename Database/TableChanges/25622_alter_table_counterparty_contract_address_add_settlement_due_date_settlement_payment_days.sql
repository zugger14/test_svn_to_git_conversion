
/* 
ADDING settlement_due_date and settlement_payment_days column in counterparty_contract_address table
*/
IF COL_LENGTH('counterparty_contract_address','settlement_due_date') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address Add settlement_due_date INT NULL
END
ELSE
PRINT 'settlement_due_date Column Already exists'


IF COL_LENGTH('counterparty_contract_address','settlement_payment_days') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address Add settlement_payment_days INT NULL
END
ELSE
PRINT 'settlement_payment_days Column Already exists'

