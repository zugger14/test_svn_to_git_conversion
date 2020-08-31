SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_counterparty_credit_info]'))
	DROP TRIGGER [dbo].[TRGUPD_counterparty_credit_info]
GO

CREATE TRIGGER [dbo].[TRGUPD_counterparty_credit_info]
ON [dbo].[counterparty_credit_info]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE counterparty_credit_info
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM counterparty_credit_info t
		INNER JOIN DELETED u ON t.counterparty_credit_info_id = u.counterparty_credit_info_id
	END
END
GO
