IF COL_LENGTH('counterparty_credit_block_trading', 'counterparty_credit_info_id') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_block_trading 
    ADD counterparty_credit_info_id INT  
END
ELSE
	PRINT('Column counterparty_credit_info_id already exists.')
GO
 
 