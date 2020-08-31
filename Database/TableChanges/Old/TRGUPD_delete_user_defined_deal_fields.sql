SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_delete_user_defined_deal_fields]'))
	DROP TRIGGER [dbo].[TRGUPD_delete_user_defined_deal_fields]
GO

CREATE TRIGGER [dbo].[TRGUPD_delete_user_defined_deal_fields]
ON [dbo].[delete_user_defined_deal_fields]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE delete_user_defined_deal_fields
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM delete_user_defined_deal_fields t
		INNER JOIN DELETED u ON t.rowid = u.rowid
	END
END
GO
