IF COL_LENGTH('counterparty_credit_info', 'buy_notional_month') IS NULL
BEGIN
	ALTER TABLE counterparty_credit_info ADD buy_notional_month NUMERIC(38, 20)
END

IF COL_LENGTH('counterparty_credit_info', 'sell_notional_month') IS NULL
BEGIN
	ALTER TABLE counterparty_credit_info ADD sell_notional_month NUMERIC(38, 20)
END


