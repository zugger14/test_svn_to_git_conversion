IF COL_LENGTH('whatif_criteria_other', 'buy_pricing_index') IS NULL
BEGIN
    ALTER TABLE whatif_criteria_other ADD buy_pricing_index INT
END
GO

IF COL_LENGTH('whatif_criteria_other', 'sell_pricing_index') IS NULL
BEGIN
    ALTER TABLE whatif_criteria_other ADD sell_pricing_index INT
END
GO

IF COL_LENGTH('whatif_criteria_other', 'buy_volume_frequency') IS NULL
BEGIN
    ALTER TABLE whatif_criteria_other ADD buy_volume_frequency CHAR(1)
END
GO

IF COL_LENGTH('whatif_criteria_other', 'sell_volume_frequency') IS NULL
BEGIN
    ALTER TABLE whatif_criteria_other ADD sell_volume_frequency CHAR(1)
END
GO

IF COL_LENGTH('whatif_criteria_other', 'block_definition') IS NULL
BEGIN
    ALTER TABLE whatif_criteria_other ADD block_definition INT
END
GO