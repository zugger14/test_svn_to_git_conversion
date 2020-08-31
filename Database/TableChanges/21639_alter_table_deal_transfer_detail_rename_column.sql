IF COL_LENGTH('deal_transfer_mapping_detail','source_book_mapping_id_to') IS NOT NULL
BEGIN
	EXEC sp_rename 'deal_transfer_mapping_detail.source_book_mapping_id_to', 'transfer_sub_book', 'COLUMN';
END

IF COL_LENGTH('deal_transfer_mapping_detail','trader_id_to') IS NOT NULL
BEGIN
	EXEC sp_rename 'deal_transfer_mapping_detail.trader_id_to', 'transfer_trader_id', 'COLUMN';
END

IF COL_LENGTH('deal_transfer_mapping_detail','counterparty_id') IS NOT NULL AND COL_LENGTH('deal_transfer_mapping_detail','counterparty_id_offset') IS NOT NULL
BEGIN
	EXEC sp_rename 'deal_transfer_mapping_detail.counterparty_id', 'transfer_counterparty_id', 'COLUMN';
END

IF COL_LENGTH('deal_transfer_mapping_detail','contract_id') IS NOT NULL AND COL_LENGTH('deal_transfer_mapping_detail','contract_id_offset') IS NOT NULL
BEGIN
	EXEC sp_rename 'deal_transfer_mapping_detail.contract_id', 'transfer_contract_id', 'COLUMN';
END

IF COL_LENGTH('deal_transfer_mapping_detail','template_id_to') IS NOT NULL
BEGIN
	EXEC sp_rename 'deal_transfer_mapping_detail.template_id_to', 'transfer_template_id', 'COLUMN';
END

IF COL_LENGTH('deal_transfer_mapping_detail','source_book_mapping_id_offset') IS NOT NULL
BEGIN
	EXEC sp_rename 'deal_transfer_mapping_detail.source_book_mapping_id_offset', 'sub_book', 'COLUMN';
END

IF COL_LENGTH('deal_transfer_mapping_detail','trader_id_offset') IS NOT NULL
BEGIN
	EXEC sp_rename 'deal_transfer_mapping_detail.trader_id_offset', 'trader_id', 'COLUMN';
END

IF COL_LENGTH('deal_transfer_mapping_detail','counterparty_id_offset') IS NOT NULL
BEGIN
	EXEC sp_rename 'deal_transfer_mapping_detail.counterparty_id_offset', 'counterparty_id', 'COLUMN';
END

IF COL_LENGTH('deal_transfer_mapping_detail','contract_id_offset') IS NOT NULL
BEGIN
	EXEC sp_rename 'deal_transfer_mapping_detail.contract_id_offset', 'contract_id', 'COLUMN';
END

IF COL_LENGTH('deal_transfer_mapping_detail','template_id_offset') IS NOT NULL
BEGIN
	EXEC sp_rename 'deal_transfer_mapping_detail.template_id_offset', 'template_id', 'COLUMN';
END

IF COL_LENGTH('deal_transfer_mapping_detail','fixed') IS NOT NULL
BEGIN
	EXEC sp_rename 'deal_transfer_mapping_detail.fixed', 'fixed_price', 'COLUMN';
END


IF COL_LENGTH('deal_transfer_mapping_detail','location_id') IS NULL
BEGIN
	ALTER TABLE deal_transfer_mapping_detail
	ADD location_id INT NULL
END

IF COL_LENGTH('deal_transfer_mapping_detail','transfer_volume') IS NULL
BEGIN
	ALTER TABLE deal_transfer_mapping_detail
	ADD transfer_volume FLOAT NULL
END

IF COL_LENGTH('deal_transfer_mapping_detail','volume_per') IS NULL
BEGIN
	ALTER TABLE deal_transfer_mapping_detail
	ADD volume_per FLOAT NULL
END

IF COL_LENGTH('deal_transfer_mapping_detail','pricing_options') IS NULL
BEGIN
	ALTER TABLE deal_transfer_mapping_detail
	ADD pricing_options CHAR(1) NULL
END

IF COL_LENGTH('deal_transfer_mapping_detail','transfer_date') IS NULL
BEGIN
	ALTER TABLE deal_transfer_mapping_detail
	ADD transfer_date DATETIME NULL
END






