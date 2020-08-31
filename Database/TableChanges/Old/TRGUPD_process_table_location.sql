SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_process_table_location]'))
	DROP TRIGGER [dbo].[TRGUPD_process_table_location]
GO

CREATE TRIGGER [dbo].[TRGUPD_process_table_location]
ON [dbo].[process_table_location]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE process_table_location
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM process_table_location t
		INNER JOIN DELETED u ON t.RECID = u.RECID
	END
END
GO
