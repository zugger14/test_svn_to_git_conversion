IF COL_LENGTH('counterparty_credit_enhancements', 'source_deal_prepay_id') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_enhancements ADD source_deal_prepay_id int NULL
END
ELSE
	PRINT('Column source_deal_prepay_id already exists.')
GO
