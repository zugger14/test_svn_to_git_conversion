SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT  *  FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_journal_entry_posting]'))
	DROP TRIGGER [dbo].[TRGUPD_journal_entry_posting]
GO

CREATE TRIGGER [dbo].[TRGUPD_journal_entry_posting]
ON [dbo].[journal_entry_posting]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE journal_entry_posting
		SET update_user = dbo.FNADBUser(),
				update_ts = GETDATE()
		FROM journal_entry_posting t
		INNER JOIN DELETED u ON t.journal_entry_posting_id = u.journal_entry_posting_id
	END
END
GO
