IF COL_LENGTH('deal_transfer_mapping', 'logical_name') IS NULL
BEGIN
    ALTER TABLE deal_transfer_mapping ADD logical_name VARCHAR(200)
END
GO

IF COL_LENGTH('deal_transfer_mapping', 'transfer_type') IS NULL
BEGIN
    ALTER TABLE deal_transfer_mapping ADD transfer_type INT
END
GO

IF COL_LENGTH('deal_transfer_mapping', 'fixed') IS NULL
BEGIN
    ALTER TABLE deal_transfer_mapping ADD fixed INT
END
ELSE
BEGIN
	ALTER TABLE deal_transfer_mapping ALTER COLUMN  fixed FLOAT
END
GO

IF COL_LENGTH('deal_transfer_mapping', 'index_adder') IS NULL
BEGIN
    ALTER TABLE deal_transfer_mapping ADD index_adder INT
END
GO

IF COL_LENGTH('deal_transfer_mapping', 'fixed_adder') IS NULL
BEGIN
    ALTER TABLE deal_transfer_mapping ADD fixed_adder INT
END
ELSE 
BEGIN
	ALTER TABLE deal_transfer_mapping ALTER COLUMN  fixed_adder FLOAT
END
GO

IF COL_LENGTH('deal_transfer_mapping', 'contract_id') IS NULL
BEGIN
    ALTER TABLE deal_transfer_mapping ADD contract_id INT
END
GO

IF COL_LENGTH('deal_transfer_mapping', 'counterparty_id') IS NULL
BEGIN
    ALTER TABLE deal_transfer_mapping ADD counterparty_id INT
END
GO

IF COL_LENGTH('deal_transfer_mapping', 'contract_id_from') IS NULL
BEGIN
    ALTER TABLE deal_transfer_mapping ADD contract_id_from INT
END
GO

