IF COL_LENGTH('ixp_import_data_source', 'ixp_ftp') IS NULL
BEGIN
    ALTER TABLE ixp_import_data_source ADD ixp_ftp INT
END
GO

