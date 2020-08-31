IF COL_LENGTH('group_meter_mapping', 'aggregate_to_meter') IS NULL
BEGIN
    ALTER TABLE group_meter_mapping ADD aggregate_to_meter INT NULL
END
GO
