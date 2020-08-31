--trader_id_offset
IF COL_LENGTH('deal_transfer_mapping', 'trader_id_offset') IS NULL
	ALTER TABLE deal_transfer_mapping ADD trader_id_offset INT
ELSE 
	PRINT 'Column ''trader_id_offset'' already exists.'

--counterparty_id_offset
IF COL_LENGTH('deal_transfer_mapping', 'counterparty_id_offset') IS NULL
	ALTER TABLE deal_transfer_mapping ADD counterparty_id_offset INT
ELSE 
	PRINT 'Column ''counterparty_id_offset'' already exists.'

--contract_id_offset
IF COL_LENGTH('deal_transfer_mapping', 'contract_id_offset') IS NULL
	ALTER TABLE deal_transfer_mapping ADD contract_id_offset INT
ELSE 
	PRINT 'Column ''contract_id_offset'' already exists.'

--template_id_offset
IF COL_LENGTH('deal_transfer_mapping', 'template_id_offset') IS NULL
	ALTER TABLE deal_transfer_mapping ADD template_id_offset INT
ELSE 
	PRINT 'Column ''template_id_offset'' already exists.'