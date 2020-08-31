IF COL_LENGTH('contract_group','shipper_id') IS NULL
ALTER TABLE contract_group 
	ADD shipper_id INT NULL
ELSE
PRINT 'colunm alreay exists'