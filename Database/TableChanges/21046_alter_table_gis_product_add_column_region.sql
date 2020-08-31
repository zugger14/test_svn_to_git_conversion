IF COL_LENGTH('Gis_Product', 'region_id') IS NULL
BEGIN
    ALTER TABLE Gis_Product ADD region_id VARCHAR(500) NULL
END
ELSE
BEGIN
    PRINT 'region_id Already Exists.'
END	

 