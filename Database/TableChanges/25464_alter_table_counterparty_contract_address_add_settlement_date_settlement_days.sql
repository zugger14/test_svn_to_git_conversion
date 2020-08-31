/* 
ADDING settlement_date and settlement_days column in counterparty_contract_address table
*/
IF COL_LENGTH('counterparty_contract_address','settlement_date') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address Add settlement_date INT NULL
END
ELSE
PRINT 'settlement_date Column Already exists'


IF COL_LENGTH('counterparty_contract_address','settlement_days') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address Add settlement_days INT NULL
END
ELSE
PRINT 'settlement_days Column Already exists'

