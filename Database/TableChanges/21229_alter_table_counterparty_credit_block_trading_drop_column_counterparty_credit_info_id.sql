IF COL_LENGTH('counterparty_credit_block_trading', 'counterparty_credit_info_id') IS NOT NULL
BEGIN
    ALTER TABLE counterparty_credit_block_trading DROP COLUMN counterparty_credit_info_id 
END
 