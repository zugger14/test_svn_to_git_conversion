IF COL_LENGTH('ixp_import_data_source', 'use_sftp') IS NULL
BEGIN
	ALTER TABLE ixp_import_data_source
	ADD use_sftp BIT DEFAULT 0
END

GO
UPDATE iids
SET use_sftp = 0
FROM ixp_import_data_source iids