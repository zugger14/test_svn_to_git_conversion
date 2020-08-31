SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_process_notes]'))
	DROP TRIGGER [dbo].[TRGUPD_process_notes]
GO

CREATE TRIGGER [dbo].[TRGUPD_process_notes]
ON [dbo].[process_notes]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE process_notes
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM process_notes t
		INNER JOIN DELETED u ON t.notes_id = u.notes_id
	END
END
GO
