IF COL_LENGTH('gis_certificate', 'facility_name') IS NULL
BEGIN
    ALTER TABLE gis_certificate ADD facility_name VARCHAR(250)
END
GO

IF COL_LENGTH('gis_certificate', 'technology') IS NULL
BEGIN	
    ALTER TABLE gis_certificate ADD technology INT
END
GO

IF COL_LENGTH('gis_certificate', 'generation_state') IS NULL
BEGIN
    ALTER TABLE gis_certificate ADD generation_state INT
END
GO

IF COL_LENGTH('gis_certificate', 'unit_id') IS NULL
BEGIN
    ALTER TABLE gis_certificate ADD unit_id VARCHAR(250)
END
GO