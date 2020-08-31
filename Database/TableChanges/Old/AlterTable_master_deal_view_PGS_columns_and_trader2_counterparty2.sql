IF COL_LENGTH('master_deal_view', 'trader2') IS NULL
BEGIN
    ALTER TABLE master_deal_view ADD trader2 VARCHAR(500)
END
GO

IF COL_LENGTH('master_deal_view', 'counterparty2') IS NULL
BEGIN
    ALTER TABLE master_deal_view ADD counterparty2 VARCHAR(500)
END
GO

IF COL_LENGTH('master_deal_view', 'origin') IS NULL
BEGIN
    ALTER TABLE master_deal_view ADD origin VARCHAR(500)
END
GO

IF COL_LENGTH('master_deal_view', 'form') IS NULL
BEGIN
    ALTER TABLE master_deal_view ADD form VARCHAR(500)
END
GO

IF COL_LENGTH('master_deal_view', 'organic') IS NULL
BEGIN
    ALTER TABLE master_deal_view ADD organic VARCHAR(500)
END
GO

IF COL_LENGTH('master_deal_view', 'attribute1') IS NULL
BEGIN
    ALTER TABLE master_deal_view ADD attribute1 VARCHAR(500)
END
GO

IF COL_LENGTH('master_deal_view', 'attribute2') IS NULL
BEGIN
    ALTER TABLE master_deal_view ADD attribute2 VARCHAR(500)
END
GO

IF COL_LENGTH('master_deal_view', 'attribute3') IS NULL
BEGIN
    ALTER TABLE master_deal_view ADD attribute3 VARCHAR(500)
END
GO

IF COL_LENGTH('master_deal_view', 'attribute4') IS NULL
BEGIN
    ALTER TABLE master_deal_view ADD attribute4 VARCHAR(500)
END
GO

IF COL_LENGTH('master_deal_view', 'attribute5') IS NULL
BEGIN
    ALTER TABLE master_deal_view ADD attribute5 VARCHAR(500)
END
GO