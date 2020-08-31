IF COL_LENGTH('transfer_mapping', 'transfer_sub_book') IS NULL
BEGIN
	ALTER TABLE transfer_mapping 
	ADD transfer_sub_book INT
END
GO

IF COL_LENGTH('transfer_mapping_detail', 'transfer_counterparty_id') IS NULL
BEGIN
	ALTER TABLE transfer_mapping_detail 
	ADD
		transfer_counterparty_id INT
END
GO

IF COL_LENGTH('transfer_mapping_detail', 'transfer_trader_id') IS NULL
BEGIN
	ALTER TABLE transfer_mapping_detail 
	ADD
		transfer_trader_id INT
END
GO

IF COL_LENGTH('transfer_mapping_detail', 'transfer_contract_id') IS NULL
BEGIN
	ALTER TABLE transfer_mapping_detail 
	ADD
		transfer_contract_id INT
END
GO

IF COL_LENGTH('transfer_mapping_detail', 'transfer_sub_book') IS NULL
BEGIN
	ALTER TABLE transfer_mapping_detail 
	ADD
		transfer_sub_book INT
END
GO