SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_counterparty_bank_info]'))
	DROP TRIGGER [dbo].[TRGUPD_counterparty_bank_info]
GO

CREATE TRIGGER [dbo].[TRGUPD_counterparty_bank_info]
ON [dbo].[counterparty_bank_info]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE counterparty_bank_info
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM counterparty_bank_info t
		INNER JOIN DELETED u ON t.bank_id = u.bank_id
	END
END
GO
