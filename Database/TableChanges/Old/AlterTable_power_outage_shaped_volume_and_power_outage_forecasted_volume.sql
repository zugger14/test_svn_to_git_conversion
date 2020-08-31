IF COL_LENGTH('power_outage_shaped_volume', 'power_outage_id') IS NULL
BEGIN
    ALTER TABLE power_outage_shaped_volume ADD power_outage_id INT
END
GO

IF COL_LENGTH('power_outage_forecasted_volume', 'power_outage_id') IS NULL
BEGIN
    ALTER TABLE power_outage_forecasted_volume ADD power_outage_id INT
END
GO
