SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_master_deal_view]'))
	DROP TRIGGER [dbo].[TRGUPD_master_deal_view]
GO

CREATE TRIGGER [dbo].[TRGUPD_master_deal_view]
ON [dbo].[master_deal_view]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE master_deal_view
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM master_deal_view t
		INNER JOIN DELETED u ON t.master_deal_id = u.master_deal_id
	END
END
GO
