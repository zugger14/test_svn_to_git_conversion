SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_post_je_report]'))
	DROP TRIGGER [dbo].[TRGUPD_post_je_report]
GO

CREATE TRIGGER [dbo].[TRGUPD_post_je_report]
ON [dbo].[post_je_report]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE post_je_report
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM post_je_report t
		INNER JOIN DELETED u ON t.id = u.id
	END
END
GO
