IF COL_LENGTH('Gis_Product', 'region_id') IS NOT NULL
BEGIN
    ALTER TABLE gis_product ALTER COLUMN region_id INT
END


