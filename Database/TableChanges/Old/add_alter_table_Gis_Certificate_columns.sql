IF COL_LENGTH('Gis_Certificate', 'state_value_id') IS NULL
BEGIN
    ALTER TABLE Gis_Certificate ADD state_value_id INT
END
GO

IF COL_LENGTH('Gis_Certificate', 'tier_type') IS NULL
BEGIN
    ALTER TABLE Gis_Certificate ADD tier_type INT
END
GO

IF COL_LENGTH('Gis_Certificate', 'contract_expiration_date') IS NULL
BEGIN
    ALTER TABLE Gis_Certificate ADD contract_expiration_date DATETIME
END
GO

IF COL_LENGTH('Gis_Certificate', 'year') IS NULL
BEGIN
    ALTER TABLE Gis_Certificate ADD [year] INT
END
GO

IF COL_LENGTH('Gis_Certificate', 'update_ts') IS NOT NULL
BEGIN
    ALTER TABLE Gis_Certificate ALTER COLUMN update_ts DATETIME 
END
GO
