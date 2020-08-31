IF COL_LENGTH('deal_type_pricing_maping', 'enable_escalation_tab') IS NULL
BEGIN
    ALTER TABLE deal_type_pricing_maping ADD enable_escalation_tab BIT DEFAULT 0
END
GO

IF COL_LENGTH('deal_type_pricing_maping', 'enable_provisional_tab') IS NULL
BEGIN
    ALTER TABLE deal_type_pricing_maping ADD enable_provisional_tab BIT DEFAULT 0
END
GO

UPDATE deal_type_pricing_maping
SET enable_escalation_tab = 0
WHERE enable_escalation_tab IS NULL
GO

UPDATE deal_type_pricing_maping
SET enable_provisional_tab = 0
WHERE enable_provisional_tab IS NULL
GO
