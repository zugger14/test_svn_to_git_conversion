SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_counterparty_epa_account]'))
	DROP TRIGGER [dbo].[TRGUPD_counterparty_epa_account]
GO

CREATE TRIGGER [dbo].[TRGUPD_counterparty_epa_account]
ON [dbo].[counterparty_epa_account]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE counterparty_epa_account
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM counterparty_epa_account t
		INNER JOIN DELETED u ON t.counterparty_epa_account_id = u.counterparty_epa_account_id
	END
END
GO
