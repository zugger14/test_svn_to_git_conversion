/* 
ADDING netting column in counterparty_contract_address table
*/
IF COL_LENGTH('counterparty_contract_address','netting') IS NULL
BEGIN
    ALTER TABLE counterparty_contract_address Add netting INT NULL
END
ELSE
PRINT 'Neeting Column Already exists'
