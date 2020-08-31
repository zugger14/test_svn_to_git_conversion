SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_manual_je_detail]'))
	DROP TRIGGER [dbo].[TRGUPD_manual_je_detail]
GO

CREATE TRIGGER [dbo].[TRGUPD_manual_je_detail]
ON [dbo].[manual_je_detail]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE manual_je_detail
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM manual_je_detail t
		INNER JOIN DELETED u ON t.manual_je_detail_id = u.manual_je_detail_id
	END
END
GO
