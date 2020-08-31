SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_journal_entry_posting_groups]'))
	DROP TRIGGER [dbo].[TRGUPD_journal_entry_posting_groups]
GO

CREATE TRIGGER [dbo].[TRGUPD_journal_entry_posting_groups]
ON [dbo].[journal_entry_posting_groups]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE journal_entry_posting_groups
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM journal_entry_posting_groups t
		INNER JOIN DELETED u ON t.posting_group_id = u.posting_group_id
	END
END
GO
