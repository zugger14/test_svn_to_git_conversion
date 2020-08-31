IF COL_LENGTH('ixp_import_data_source', 'ftp_url') IS NULL
BEGIN
    ALTER TABLE ixp_import_data_source ADD ftp_url VARCHAR(MAX);
END
GO

IF COL_LENGTH('ixp_import_data_source', 'ftp_username') IS NULL
BEGIN
    ALTER TABLE ixp_import_data_source ADD ftp_username VARCHAR(50)
END
GO

IF COL_LENGTH('ixp_import_data_source', 'ftp_password') IS NULL
BEGIN
    ALTER TABLE ixp_import_data_source ADD ftp_password VARBINARY(1024)
END
GO
