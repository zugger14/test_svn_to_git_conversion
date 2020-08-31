IF COL_LENGTH('ixp_import_data_source', 'ixp_ftp') IS NOT NULL
BEGIN
    ALTER TABLE ixp_import_data_source ALTER COLUMN ixp_ftp BIT
END
ELSE PRINT 'Column ixp_ftp doesnot exists.'
GO