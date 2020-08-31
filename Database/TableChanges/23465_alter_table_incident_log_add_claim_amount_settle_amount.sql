IF COL_LENGTH('incident_log', 'claim_amount') IS NULL
BEGIN
    ALTER TABLE incident_log ADD claim_amount FLOAT
END
GO

IF COL_LENGTH('incident_log', 'settle_amount') IS NULL
BEGIN
    ALTER TABLE incident_log ADD settle_amount FLOAT
END
GO

IF COL_LENGTH('incident_log', 'claim_amount_currency') IS NULL
BEGIN
    ALTER TABLE incident_log ADD claim_amount_currency INT
END
GO

IF COL_LENGTH('incident_log', 'settle_amount_currency') IS NULL
BEGIN
    ALTER TABLE incident_log ADD settle_amount_currency INT
END
GO