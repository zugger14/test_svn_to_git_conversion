IF COL_LENGTH('ixp_import_data_source', 'enable_email_import') IS NULL
BEGIN
    ALTER TABLE ixp_import_data_source ADD enable_email_import CHAR(1)
END
GO

IF COL_LENGTH('ixp_import_data_source', 'send_email_import_reply') IS NULL
BEGIN
    ALTER TABLE ixp_import_data_source ADD send_email_import_reply CHAR(1)
END
GO