IF OBJECT_ID (N'source_mifid_audit_log', N'U') IS NOT NULL
BEGIN
	PRINT 'Table already exists.'
	RETURN
END

CREATE TABLE [dbo].[source_mifid_audit_log] (
	[source_mifid_audit_log_id] INT IDENTITY(1, 1) CONSTRAINT [pk_source_mifid_audit_log] PRIMARY KEY CLUSTERED WITH (IGNORE_DUP_KEY = OFF) NOT NULL,
	[deal_id] VARCHAR(200) COLLATE DATABASE_DEFAULT NULL,
	[response_status] VARCHAR(200) COLLATE DATABASE_DEFAULT NULL,
	[response_message] VARCHAR(8000) COLLATE DATABASE_DEFAULT NULL,
	[error_code] VARCHAR(100) COLLATE DATABASE_DEFAULT NULL,
	[response_file_name] VARCHAR(80) COLLATE DATABASE_DEFAULT NULL,
	[process_id] VARCHAR(100) COLLATE DATABASE_DEFAULT NULL,
	[create_user] VARCHAR(50) COLLATE DATABASE_DEFAULT NULL DEFAULT ([dbo].[FNADBUser]()),
	[create_ts] DATETIME NULL DEFAULT (GETDATE()),
	[update_user] VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,
	[update_ts] DATETIME NULL
)
GO

IF OBJECT_ID(N'[dbo].[TRGUPD_source_mifid_audit_log]', N'TR') IS NOT NULL
	DROP TRIGGER [dbo].[TRGUPD_source_mifid_audit_log]
GO

CREATE TRIGGER [dbo].[TRGUPD_source_mifid_audit_log]
	ON [dbo].[source_mifid_audit_log]
FOR UPDATE
AS
UPDATE smal
SET update_user = dbo.FNADBUser(),
	update_ts = GETDATE()
FROM source_mifid_audit_log smal
INNER JOIN deleted d ON d.source_mifid_audit_log_id = smal.source_mifid_audit_log_id
GO