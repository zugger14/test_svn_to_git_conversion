DECLARE @constraint_name VARCHAR(200)
IF COL_LENGTH('deal_transfer_mapping','source_book_mapping_id_offset') IS NOT NULL
BEGIN
	ALTER TABLE deal_transfer_mapping
	DROP COLUMN source_book_mapping_id_offset
END

IF COL_LENGTH('deal_transfer_mapping','trader_id_offset') IS NOT NULL
BEGIN
	ALTER TABLE deal_transfer_mapping
	DROP COLUMN trader_id_offset
END

IF COL_LENGTH('deal_transfer_mapping','counterparty_id_offset') IS NOT NULL
BEGIN
	ALTER TABLE deal_transfer_mapping
	DROP COLUMN counterparty_id_offset
END

IF COL_LENGTH('deal_transfer_mapping','contract_id_offset') IS NOT NULL
BEGIN
	ALTER TABLE deal_transfer_mapping
	DROP COLUMN contract_id_offset
END

IF COL_LENGTH('deal_transfer_mapping','template_id_offset') IS NOT NULL
BEGIN
	ALTER TABLE deal_transfer_mapping
	DROP COLUMN template_id_offset
END

IF COL_LENGTH('deal_transfer_mapping','source_book_mapping_id_to') IS NOT NULL
BEGIN
	SELECT @constraint_name = CONSTRAINT_NAME FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE
	WHERE TABLE_NAME = 'deal_transfer_mapping'
	AND COLUMN_NAME = 'source_book_mapping_id_to'

	IF @constraint_name IS NOT NULL
	BEGIN
		EXEC ('ALTER TABLE deal_transfer_mapping
			  DROP CONSTRAINT ' + @constraint_name )
	END

	ALTER TABLE deal_transfer_mapping
	DROP COLUMN source_book_mapping_id_to
END

IF COL_LENGTH('deal_transfer_mapping','trader_id_to') IS NOT NULL
BEGIN
	SELECT @constraint_name = CONSTRAINT_NAME FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE
	WHERE TABLE_NAME = 'deal_transfer_mapping'
	AND COLUMN_NAME = 'trader_id_to'

	IF @constraint_name IS NOT NULL
	BEGIN
		EXEC ('ALTER TABLE deal_transfer_mapping
			  DROP CONSTRAINT ' + @constraint_name )
	END

	ALTER TABLE deal_transfer_mapping
	DROP COLUMN trader_id_to
END

IF COL_LENGTH('deal_transfer_mapping','counterparty_id') IS NOT NULL
BEGIN
	ALTER TABLE deal_transfer_mapping
	DROP COLUMN counterparty_id
END

IF COL_LENGTH('deal_transfer_mapping','contract_id') IS NOT NULL
BEGIN
	ALTER TABLE deal_transfer_mapping
	DROP COLUMN contract_id
END

IF COL_LENGTH('deal_transfer_mapping','template_id_to') IS NOT NULL
BEGIN
	ALTER TABLE deal_transfer_mapping
	DROP COLUMN template_id_to
END

IF COL_LENGTH('deal_transfer_mapping','transfer_type') IS NOT NULL
BEGIN
	ALTER TABLE deal_transfer_mapping
	DROP COLUMN transfer_type
END

IF COL_LENGTH('deal_transfer_mapping','fixed') IS NOT NULL
BEGIN
	ALTER TABLE deal_transfer_mapping
	DROP COLUMN fixed
END

IF COL_LENGTH('deal_transfer_mapping','index_adder') IS NOT NULL
BEGIN
	ALTER TABLE deal_transfer_mapping
	DROP COLUMN index_adder
END

IF COL_LENGTH('deal_transfer_mapping','fixed_adder') IS NOT NULL
BEGIN
	ALTER TABLE deal_transfer_mapping
	DROP COLUMN fixed_adder
END

  
 
  
  
  