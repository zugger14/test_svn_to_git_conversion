IF COL_LENGTH('Gis_Product', 'technology_id') IS NULL
BEGIN
    ALTER TABLE Gis_Product ADD technology_id INT
END
