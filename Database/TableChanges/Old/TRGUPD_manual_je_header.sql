SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_manual_je_header]'))
	DROP TRIGGER [dbo].[TRGUPD_manual_je_header]
GO

CREATE TRIGGER [dbo].[TRGUPD_manual_je_header]
ON [dbo].[manual_je_header]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE manual_je_header
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM manual_je_header t
		INNER JOIN DELETED u ON t.manual_je_id = u.manual_je_id
	END
END
GO

