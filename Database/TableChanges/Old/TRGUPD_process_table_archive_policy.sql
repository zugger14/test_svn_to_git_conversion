SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_process_table_archive_policy]'))
	DROP TRIGGER [dbo].[TRGUPD_process_table_archive_policy]
GO

CREATE TRIGGER [dbo].[TRGUPD_process_table_archive_policy]
ON [dbo].[process_table_archive_policy]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE process_table_archive_policy
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM process_table_archive_policy t
		INNER JOIN DELETED u ON t.RECID = u.RECID
	END
END
GO
