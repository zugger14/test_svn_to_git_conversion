--Delete ixp_ftp and add is_ftp
IF COL_LENGTH('ixp_import_data_source','ixp_ftp') IS NOT NULL
BEGIN
	ALTER TABLE ixp_import_data_source DROP COLUMN ixp_ftp
END
ELSE PRINT 'Column ixp_ftp does not exist.'
GO

IF COL_LENGTH('ixp_import_data_source','is_ftp') IS NULL
BEGIN
	ALTER TABLE ixp_import_data_source ADD is_ftp BIT DEFAULT 0
END
ELSE PRINT 'Column is_ftp already added.'