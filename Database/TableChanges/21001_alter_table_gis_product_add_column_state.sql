IF COL_LENGTH('Gis_Product', 'state') IS NULL
BEGIN
    ALTER TABLE Gis_Product ADD state INT NULL
END
ELSE
BEGIN
    PRINT 'state Already Exists.'
END	

 