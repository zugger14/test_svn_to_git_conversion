SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_deal_confirmation_status]'))
	DROP TRIGGER [dbo].TRGUPD_deal_confirmation_status
GO

CREATE TRIGGER [dbo].TRGUPD_deal_confirmation_status
ON [dbo].[deal_confirmation_status]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE deal_confirmation_status
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM deal_confirmation_status t
		INNER JOIN DELETED u ON t.deal_confirmation_status_id = u.deal_confirmation_status_id
	END
END
GO




