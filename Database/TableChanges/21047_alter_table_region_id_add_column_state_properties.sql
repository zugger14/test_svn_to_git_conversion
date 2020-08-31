IF COL_LENGTH('state_properties', 'region_id') IS NULL
BEGIN
    ALTER TABLE state_properties ADD region_id VARCHAR(2000) NULL
END
GO
