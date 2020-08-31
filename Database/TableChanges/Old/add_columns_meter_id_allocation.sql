IF COL_LENGTH('meter_id_allocation', 'counterparty') IS NULL
BEGIN
    ALTER TABLE meter_id_allocation ADD counterparty INT
END
GO

IF COL_LENGTH('meter_id_allocation', 'commodity') IS NULL
BEGIN
    ALTER TABLE meter_id_allocation ADD commodity INT
END
GO

IF COL_LENGTH('meter_id_allocation', 'country') IS NULL
BEGIN
    ALTER TABLE meter_id_allocation ADD country INT
END
GO