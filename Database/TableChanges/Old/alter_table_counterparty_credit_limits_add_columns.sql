IF COL_LENGTH('counterparty_credit_limits', 'threshold_provided') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_limits ADD threshold_provided FLOAT
END
GO

IF COL_LENGTH('counterparty_credit_limits', 'threshold_received') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_limits ADD threshold_received FLOAT
END
GO