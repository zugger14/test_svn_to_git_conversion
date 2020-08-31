SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_counterparty_limits]'))
	DROP TRIGGER [dbo].[TRGUPD_counterparty_limits]
GO

CREATE TRIGGER [dbo].[TRGUPD_counterparty_limits]
ON [dbo].[counterparty_limits]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE counterparty_limits
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM counterparty_limits t
		INNER JOIN DELETED u ON t.counterparty_limit_id = u.counterparty_limit_id
	END
END
GO
