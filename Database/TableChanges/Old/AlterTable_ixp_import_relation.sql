IF COL_LENGTH('ixp_import_relation', 'delimiter') IS NULL
BEGIN
    ALTER TABLE ixp_import_relation ADD delimiter VARCHAR(10)
END
GO
